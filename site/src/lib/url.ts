import { SITE } from "../content/site";

const base = (import.meta.env.BASE_URL as string) || "/";

/** Chemin interne tenant compte du BASE_PATH (GitHub Pages sous-dossier). */
export const href = (path = "/") => {
  const clean = path.replace(/^\//, "");
  return base.replace(/\/$/, "") + "/" + clean;
};

/** URL absolue canonique. */
export const abs = (path = "/") => {
  const clean = path.replace(/^\//, "");
  const basePath = base.replace(/\/$/, "");
  return `${SITE.url}${basePath}/${clean}`;
};

export const regionPath = (slug: string) => `/regions/${slug}/`;
