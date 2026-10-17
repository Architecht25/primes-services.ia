import { GENERAL_FAQ, REGIONS, REGION_ORDER, RENOVATE, SITE, type Region } from "../content/site";
import { abs } from "../lib/url";
import { PAGES, type PageMeta } from "./pages";

const esc = (s: string) => s.replace(/&/g, "&amp;").replace(/"/g, "&quot;").replace(/</g, "&lt;");
const ld = (o: unknown) => `<script type="application/ld+json">${JSON.stringify(o).replace(/</g, "\\u003c")}</script>`;

const ORG_ID = `${SITE.url}/#organization`;
const SITE_ID = `${SITE.url}/#website`;
const APP_ID = `${RENOVATE.url}#software`;

const faqLd = (items: { q: string; a: string }[]) => ({
  "@type": "FAQPage",
  mainEntity: items.map((f) => ({ "@type": "Question", name: f.q, acceptedAnswer: { "@type": "Answer", text: f.a } })),
});

const organization = () => ({
  "@type": ["Organization", "ProfessionalService"],
  "@id": ORG_ID,
  name: SITE.name,
  alternateName: "Primes-Services",
  url: abs("/"),
  logo: { "@type": "ImageObject", url: abs("/logo-512.png"), width: 512, height: 512 },
  image: abs("/og.jpg"),
  description:
    "Primes Services est une société belge de conseil en primes, subsides et prêts à taux 0 % pour la rénovation, active depuis plus de 15 ans en Wallonie, en Flandre et à Bruxelles. Elle exploite l'application Ren0vate.",
  slogan: "Primes, subsides et prêts à taux 0 % : tout se gère dans Ren0vate.",
  foundingDate: String(SITE.foundingYear),
  email: SITE.email,
  telephone: SITE.phone,
  areaServed: [
    { "@type": "Country", name: "Belgique" },
    { "@type": "AdministrativeArea", name: "Wallonie" },
    { "@type": "AdministrativeArea", name: "Flandre" },
    { "@type": "AdministrativeArea", name: "Région de Bruxelles-Capitale" },
  ],
  knowsAbout: [
    "Primes à la rénovation en Belgique",
    "Prêts à taux 0 % pour la rénovation énergétique",
    "Rénopack", "Rénoprêt", "Mijn VerbouwPremie", "Mijn VerbouwLening", "Crédit EcoRéno",
    "Monuments et Sites", "Petit Patrimoine", "Primes communales",
    "Gestion de chantier de rénovation",
  ],
  contactPoint: [
    { "@type": "ContactPoint", contactType: "customer support", email: SITE.email, telephone: SITE.phone, availableLanguage: ["fr", "nl"], areaServed: "BE" },
    { "@type": "ContactPoint", contactType: "technical support", email: SITE.techEmail, availableLanguage: ["fr"], areaServed: "BE", description: "Support technique et application Ren0vate" },
  ],
  sameAs: [RENOVATE.url],
  owns: { "@id": APP_ID },
});

const renovateApp = () => ({
  "@type": "SoftwareApplication",
  "@id": APP_ID,
  name: RENOVATE.name,
  alternateName: "Ren0vate – le passeport numérique de votre logement",
  url: RENOVATE.url,
  description: RENOVATE.description,
  applicationCategory: "BusinessApplication",
  operatingSystem: "Web",
  inLanguage: "fr",
  countriesSupported: "BE",
  provider: { "@id": ORG_ID },
  offers: { "@type": "Offer", price: "0", priceCurrency: "EUR", description: "Premier projet gratuit ; fonctions multi-biens et professionnelles sur abonnement.", url: RENOVATE.pricing },
  featureList: [
    "Identification des primes et prêts à taux 0 % selon la région et les revenus",
    "Gestion de chantier par lot : planning, avancement, messagerie",
    "Comparateur de devis",
    "Dossiers et documents avec alertes de pièces manquantes",
    "Journal de chantier avec photos géolocalisées et procès-verbaux",
    "Passeport numérique du logement et dossier d'intervention ultérieure (DIU)",
  ],
});

const breadcrumb = (items: [string, string][]) => ({
  "@type": "BreadcrumbList",
  itemListElement: items.map(([name, path], i) => ({ "@type": "ListItem", position: i + 1, name, item: abs(path) })),
});

const regionService = (r: Region) => ({
  "@type": "ItemList",
  name: `Aides à la rénovation disponibles – ${r.name}`,
  itemListElement: r.schemes.map((s, i) => ({ "@type": "ListItem", position: i + 1, name: s.name, description: s.text })),
});

export function headFor(page: PageMeta): string {
  const url = abs(page.path);
  const graph: unknown[] = [];

  const webpage = {
    "@type": page.id === "home" ? "WebPage" : "WebPage",
    "@id": `${url}#webpage`,
    url,
    name: page.title,
    description: page.description,
    inLanguage: SITE.locale,
    isPartOf: { "@id": SITE_ID },
    about: { "@id": ORG_ID },
    dateModified: SITE.verifiedISO,
    primaryImageOfPage: abs("/og.jpg"),
  };
  graph.push(webpage);

  if (page.id === "home") {
    graph.push(
      { "@type": "WebSite", "@id": SITE_ID, url: abs("/"), name: SITE.name, inLanguage: SITE.locale, publisher: { "@id": ORG_ID } },
      organization(),
      renovateApp(),
      { ...faqLd(GENERAL_FAQ), "@id": `${url}#faq` },
    );
  } else if (page.id !== "notfound") {
    const r = REGIONS[page.id];
    graph.push(
      breadcrumb([["Accueil", "/"], [r.name, page.path]]),
      regionService(r),
      { ...faqLd(r.faq), "@id": `${url}#faq` },
      organization(),
    );
  }

  const tags = [
    `<title>${esc(page.title)}</title>`,
    `<meta name="description" content="${esc(page.description)}" />`,
    `<link rel="canonical" href="${url}" />`,
    `<link rel="alternate" hreflang="fr-BE" href="${url}" />`,
    `<link rel="alternate" hreflang="x-default" href="${url}" />`,
    `<meta name="robots" content="${page.noindex ? "noindex,follow" : "index,follow,max-image-preview:large,max-snippet:-1,max-video-preview:-1"}" />`,
    `<meta name="author" content="${SITE.name}" />`,
    `<meta property="og:type" content="website" />`,
    `<meta property="og:site_name" content="${SITE.name}" />`,
    `<meta property="og:locale" content="fr_BE" />`,
    `<meta property="og:title" content="${esc(page.title)}" />`,
    `<meta property="og:description" content="${esc(page.description)}" />`,
    `<meta property="og:url" content="${url}" />`,
    `<meta property="og:image" content="${abs("/og.jpg")}" />`,
    `<meta property="og:image:width" content="1200" />`,
    `<meta property="og:image:height" content="630" />`,
    `<meta property="og:image:alt" content="Primes Services – aides à la rénovation en Belgique et application Ren0vate" />`,
    `<meta name="twitter:card" content="summary_large_image" />`,
    `<meta name="twitter:title" content="${esc(page.title)}" />`,
    `<meta name="twitter:description" content="${esc(page.description)}" />`,
    `<meta name="twitter:image" content="${abs("/og.jpg")}" />`,
    `<meta name="geo.region" content="BE" />`,
    `<meta name="geo.placename" content="Belgique" />`,
    `<link rel="alternate" type="text/plain" href="${abs("/llms.txt")}" title="llms.txt" />`,
    ld({ "@context": "https://schema.org", "@graph": graph }),
  ];
  return tags.join("\n    ");
}

export const PAGES_BY_ID = Object.fromEntries(PAGES.map((p) => [p.id, p]));
export { REGION_ORDER };
