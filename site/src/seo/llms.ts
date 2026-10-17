import { GENERAL_FAQ, KIND_LABEL, REGIONS, REGION_ORDER, RENOVATE, SITE, STATS } from "../content/site";
import { abs } from "../lib/url";
import { LEGACY_REDIRECTS, PAGES } from "./pages";

const intro = `Primes Services est une société belge de conseil en primes, subsides et prêts à taux 0 % pour la rénovation (Wallonie, Flandre, Bruxelles-Capitale), active depuis ${SITE.foundingYear}. Toutes les nouvelles demandes passent exclusivement par Ren0vate, son application de gestion de chantier et de subsides.`;

/** /llms.txt — index concis pour les agents et moteurs IA (spécification llmstxt.org). */
export function llmsTxt(): string {
  return `# ${SITE.name}

> ${intro}

Informations vérifiées le ${SITE.verifiedLabel}. Indicatif : seules les administrations régionales font foi. Langue : français (Belgique).

## Pages
- [Accueil](${abs("/")}): présentation de Primes Services, de Ren0vate et des aides par région
${REGION_ORDER.map((s) => `- [${REGIONS[s].name}](${abs(`/regions/${s}/`)}): ${REGIONS[s].headline}`).join("\n")}

## Application
- [Ren0vate](${RENOVATE.url}): ${RENOVATE.description}
- [Tarifs Ren0vate](${RENOVATE.pricing}): premier projet gratuit, fonctions professionnelles sur abonnement

## Contact
- Courriel : ${SITE.email}
- Support technique / Ren0vate : ${SITE.techEmail}
- Téléphone : ${SITE.phone}

## Optional
- [Version texte complète](${abs("/llms-full.txt")}): toutes les aides, conditions et questions fréquentes en Markdown
`;
}

/** /llms-full.txt — contenu complet en Markdown, sans navigation ni scripts. */
export function llmsFullTxt(): string {
  const regions = REGION_ORDER.map((s) => {
    const r = REGIONS[s];
    return `## ${r.name} (${r.fullName})

Statut : ${r.status}.

${r.summary}

### Dispositifs disponibles
${r.schemes.map((x) => `- **${x.name}** (${KIND_LABEL[x.kind]}) : ${x.text}`).join("\n")}

### Conditions à connaître
${r.conditions.map((e) => `- ${e}`).join("\n")}

### À venir
${r.upcoming.map((e) => `- ${e}`).join("\n")}

Sources consultées : ${r.sourcesChecked}

### Sources officielles
- ${r.authority.name}${r.authority.phone ? ` – ${r.authority.phone}` : ""} : ${r.authority.url}
${r.officialLinks.map((l) => `- ${l.label} : ${l.url}`).join("\n")}

### Questions fréquentes – ${r.name}
${r.faq.map((f) => `**${f.q}**\n${f.a}`).join("\n\n")}

Page : ${abs(`/regions/${s}/`)}`;
  }).join("\n\n---\n\n");

  return `# ${SITE.name} – contenu complet

> ${intro}

Dernière vérification : ${SITE.verifiedLabel}. Les informations sont indicatives et issues de sources publiques ; Primes Services n'est pas un organisme public.

## Chiffres clés
${STATS.map((s) => `- ${s.prefix}${s.value.toLocaleString("fr-BE")}${s.suffix} ${s.label}`).join("\n")}

## Ren0vate
${RENOVATE.name} – ${RENOVATE.tagline}. ${RENOVATE.description}
- Application : ${RENOVATE.url}
- Inscription : ${RENOVATE.signup}
- Tarifs : ${RENOVATE.pricing} (premier projet gratuit ; fonctions multi-biens et professionnelles sur abonnement)

## Aujourd'hui et à venir
- En vigueur depuis le 1er mars 2026 – Flandre : Mijn VerbouwLening (4 000 à 60 000 €, 25 ans maximum, 1,5 % / 0,5 % / 0 % selon la catégorie) et Mijn VerbouwPremie.
- En vigueur depuis le 1er octobre 2026 – Wallonie : Rénopack (taux 0 %, 15 à 50 % du capital non remboursé) et Rénoprêt.
- Printemps 2027 – Bruxelles : prêts énergie et rénovation à taux 0 % annoncés par le gouvernement bruxellois (source : presse, modalités non publiées).
- 1er janvier 2028 – Wallonie : l'Agence wallonne de l'Habitation pilote le dispositif.

---

${regions}

---

## Questions générales
${GENERAL_FAQ.map((f) => `**${f.q}**\n${f.a}`).join("\n\n")}

## Contact
- Courriel : ${SITE.email}
- Support technique / Ren0vate : ${SITE.techEmail}
- Téléphone : ${SITE.phone}
`;
}

export function robotsTxt(): string {
  const bots = [
    "GPTBot", "OAI-SearchBot", "ChatGPT-User", "ClaudeBot", "Claude-SearchBot", "Claude-User", "anthropic-ai",
    "PerplexityBot", "Perplexity-User", "Google-Extended", "Applebot-Extended", "Bingbot", "Googlebot",
  ];
  return `# Primes Services – les robots d'exploration classiques et les agents IA sont les bienvenus.
User-agent: *
Allow: /

${bots.map((b) => `User-agent: ${b}\nAllow: /`).join("\n\n")}

Sitemap: ${abs("/sitemap.xml")}
`;
}

export function sitemapXml(): string {
  const urls = PAGES.map(
    (p) => `  <url>\n    <loc>${abs(p.path)}</loc>\n    <lastmod>${SITE.verifiedISO}</lastmod>\n    <changefreq>${p.id === "home" ? "monthly" : "monthly"}</changefreq>\n  </url>`,
  ).join("\n");
  return `<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n${urls}\n</urlset>\n`;
}

export const legacyPaths = () => Object.entries(LEGACY_REDIRECTS);
