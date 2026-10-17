import { REGIONS, REGION_ORDER, type RegionSlug } from "../content/site";
import type { PageId } from "../App";

export type PageMeta = {
  id: PageId;
  path: string; // chemin canonique sans base, avec slash final
  title: string;
  description: string;
  noindex?: boolean;
};

export const PAGES: PageMeta[] = [
  {
    id: "home",
    path: "/",
    title: "Primes Services – Aides à la rénovation en Belgique | Ren0vate",
    description:
      "Primes, subsides et prêts à taux 0 % pour rénover en Wallonie, Flandre et Bruxelles : ce qui reste en 2026, et comment tout gérer dans l'application Ren0vate.",
  },
  ...REGION_ORDER.map((slug: RegionSlug): PageMeta => {
    const r = REGIONS[slug];
    return {
      id: slug,
      path: `/regions/${slug}/`,
      title: `Primes et prêts à taux 0 % – ${r.name} (2026) | Primes Services`,
      description: `${r.headline}. ${r.summary}`.slice(0, 300).replace(/\s+\S*$/, "…"),
    };
  }),
];

/** Anciennes URLs de l'application Rails → nouvelles cibles (pages de redirection statiques). */
export const LEGACY_REDIRECTS: Record<string, string> = {
  "/pages/about/": "/",
  "/pages/renovate/": "/#renovate",
  "/pages/simulation/": "/#regions",
  "/contacts/new/": "/#contact",
  ...Object.fromEntries(
    REGION_ORDER.flatMap((s) => [
      [`/simulation/${s}/`, `/regions/${s}/`],
      [`/simulation/${s}/primes/`, `/regions/${s}/`],
      [`/simulation/${s}/prets/`, `/regions/${s}/`],
      [`/regions/${s}/villes/`, `/regions/${s}/`],
    ]),
  ),
};

