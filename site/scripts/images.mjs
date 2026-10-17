// Génère les images optimisées (webp) de public/img à partir des photos sources.
// Usage : npm run images -- <dossier-des-sources>
// Les originaux (plusieurs Mo) ne sont pas versionnés ; seuls les webp le sont.
import sharp from "sharp";
import { mkdir } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const src = path.resolve(process.argv[2] ?? path.join(here, "../../app/assets/images"));
const out = path.join(here, "../public/img");

const JOBS = [
  { file: "louis-colbee-s1XM2juGJAg-unsplash.jpg", name: "chantier", widths: [640, 1100] },
  { file: "ernys-cDw2cA9bbYs-unsplash.jpg", name: "artisan", widths: [640, 1100] },
  { file: "benjamin-jopen-2SfssudtyIA-unsplash.jpg", name: "solaire", widths: [640, 1100] },
  { file: "daan-oosters-jmbUa-u_Uts-unsplash.jpg", name: "bruxelles", widths: [800, 1600] },
];

await mkdir(out, { recursive: true });
for (const job of JOBS) {
  for (const w of job.widths) {
    const info = await sharp(path.join(src, job.file))
      .rotate()
      .resize({ width: w, withoutEnlargement: true })
      .webp({ quality: 72, effort: 5 })
      .toFile(path.join(out, `${job.name}-${w}.webp`));
    console.log(`${job.name}-${w}.webp  ${info.width}x${info.height}  ${(info.size / 1024).toFixed(0)} Ko`);
  }
}

// --- Icônes et image de partage (Open Graph) ---------------------------------
import { readFile, writeFile } from "node:fs/promises";
const pub = path.join(here, "../public");
const favicon = await readFile(path.join(pub, "favicon.svg"));
await sharp(favicon, { density: 600 }).resize(180, 180).png().toFile(path.join(pub, "apple-touch-icon.png"));
await sharp(favicon, { density: 600 }).resize(512, 512).png().toFile(path.join(pub, "logo-512.png"));

const logoPaths = `<g fill="#4db885" transform="translate(70 70) scale(0.075) translate(-456 -486)"><path d="M776 486H1100A318 320 0 0 1 1418 806H1100A324 320 0 0 1 776 486Z"/><path d="M1418 837H1100A324 319 0 0 0 776 1156H1100A318 319 0 0 0 1418 837Z"/><path d="M456 1156H776A320 320 0 0 1 456 1476Z"/></g>`;
const overlay = Buffer.from(`<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="630">
  <defs><linearGradient id="g" x1="0" x2="1"><stop offset="0" stop-color="#0a1622" stop-opacity=".96"/><stop offset=".6" stop-color="#0a1622" stop-opacity=".78"/><stop offset="1" stop-color="#0a1622" stop-opacity=".25"/></linearGradient></defs>
  <rect width="1200" height="630" fill="url(#g)"/>
  ${logoPaths}
  <text x="160" y="118" font-family="DejaVu Sans, Arial, sans-serif" font-size="30" font-weight="700" fill="#ffffff">Primes Services</text>
  <text x="70" y="330" font-family="DejaVu Serif, Georgia, serif" font-size="68" font-weight="700" fill="#ffffff">Primes, subsides et prêts</text>
  <text x="70" y="412" font-family="DejaVu Serif, Georgia, serif" font-size="68" font-weight="700" fill="#ffffff">à taux 0 % : tout se gère</text>
  <text x="70" y="494" font-family="DejaVu Serif, Georgia, serif" font-size="68" font-weight="700" fill="#e8a020">dans Ren0vate.</text>
  <text x="70" y="568" font-family="DejaVu Sans, Arial, sans-serif" font-size="26" fill="#b8cad8">Wallonie · Flandre · Bruxelles — aides à la rénovation 2026</text>
</svg>`);
await sharp(path.join(src, "daan-oosters-jmbUa-u_Uts-unsplash.jpg"))
  .resize(1200, 630, { fit: "cover", position: "centre" })
  .composite([{ input: overlay }])
  .jpeg({ quality: 82, mozjpeg: true })
  .toFile(path.join(pub, "og.jpg"));
console.log("icônes + og.jpg générés");
