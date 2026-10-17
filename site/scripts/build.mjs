// Build statique : bundle client (Vite) + prérendu HTML de chaque page (SSR) + fichiers SEO/GEO.
//   SITE_URL=https://www.primes-services.be BASE_PATH=/ npm run build
import { build } from "vite";
import { mkdir, readFile, rm, writeFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const dist = path.join(root, "dist");
const ssrDir = path.join(root, ".dist-ssr");

if (process.env.SITE_URL) process.env.VITE_SITE_URL = process.env.SITE_URL;

await rm(dist, { recursive: true, force: true });
await rm(ssrDir, { recursive: true, force: true });

console.log("▸ bundle client");
await build({ root, logLevel: "warn" });

console.log("▸ bundle SSR");
await build({ root, logLevel: "warn", build: { ssr: "src/entry-server.tsx", outDir: ssrDir, emptyOutDir: true, rollupOptions: { output: { entryFileNames: "entry-server.mjs" } } }, ssr: { noExternal: [] } });

const mod = await import(pathToFileURL(path.join(ssrDir, "entry-server.mjs")).href);
const { render, headFor, PAGES, LEGACY_REDIRECTS, llmsTxt, llmsFullTxt, robotsTxt, sitemapXml, abs, href, SITE } = mod;

const template = await readFile(path.join(dist, "index.html"), "utf8");
const write = async (rel, content) => {
  const file = path.join(dist, rel);
  await mkdir(path.dirname(file), { recursive: true });
  await writeFile(file, content);
};
const page = (meta) =>
  template.replace("<!--head-->", headFor(meta)).replace("<!--app-->", render(meta.id)).replace("__PAGE__", meta.id);

console.log("▸ prérendu");
for (const meta of PAGES) {
  await write(path.join(meta.path, "index.html"), page(meta));
  console.log("  ", meta.path);
}
await write("404.html", page({ id: "notfound", path: "/404.html", title: "Page introuvable | Primes Services", description: "Cette page n'existe pas.", noindex: true }));

// Anciennes URLs de l'app Rails (indexées par Google) → redirections statiques
for (const [from, to] of Object.entries(LEGACY_REDIRECTS)) {
  const target = abs(to);
  await write(path.join(from, "index.html"), `<!doctype html>
<html lang="fr-BE"><head><meta charset="utf-8"><title>Redirection – Primes Services</title>
<link rel="canonical" href="${target}"><meta http-equiv="refresh" content="0; url=${href(to)}">
<meta name="viewport" content="width=device-width, initial-scale=1"></head>
<body><p>Cette page a déménagé : <a href="${href(to)}">${target}</a></p>
<script>location.replace(${JSON.stringify(href(to))}+location.hash)</script></body></html>`);
}

await write("robots.txt", robotsTxt());
await write("sitemap.xml", sitemapXml());
await write("llms.txt", llmsTxt());
await write("llms-full.txt", llmsFullTxt());

const host = new URL(SITE.url).host;
if (!host.endsWith(".github.io") && (process.env.BASE_PATH ?? "/") === "/") await write("CNAME", host + "\n");

await rm(ssrDir, { recursive: true, force: true });
console.log("✔ dist/ prêt –", SITE.url);
