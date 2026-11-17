# Primes Services – landing page statique

Site vitrine **100 % statique** (hébergé sur GitHub Pages) : présentation de Primes Services, aides à la rénovation restantes par région, et information sur l'**arrêt des activités** (janvier 2027 ; plus de contact possible depuis le 15 novembre 2026). Aucune coordonnée de contact ni lien vers Ren0vate n'est publié.

- **Stack** : Vite + React 19 + TypeScript, Tailwind CSS 4, Framer Motion (`framer-motion`), polices auto-hébergées (Fraunces, Inter).
- **SEO / GEO** : chaque page est **prérendue en HTML** au build (les crawlers et agents IA qui n'exécutent pas JavaScript lisent tout le contenu), avec JSON-LD (`Organization`, `ProfessionalService`, `FAQPage` (pages régionales), `BreadcrumbList`), `sitemap.xml`, `robots.txt` (agents IA autorisés), `llms.txt` et `llms-full.txt`.
- **Anciennes URLs** de l'app Rails (`/regions/:region`, `/simulation/...`, `/pages/...`, `/contacts/new`) : `/regions/:region/` est conservée, les autres redirigent (pages de redirection statiques).

## Commandes

```bash
cd site
npm ci
npm run dev        # développement (http://localhost:5173)
npm run build      # prérendu complet dans dist/
npm run preview    # servir dist/ (http://localhost:4173)
npm run typecheck
npm run images -- <dossier>   # régénère les .webp, icônes et og.jpg depuis les photos sources
```

Variables de build : `SITE_URL` (domaine canonique, défaut `https://www.primes-services.be`) et `BASE_PATH` (`/` avec domaine personnalisé ; `/<repo>/` sur `github.io/<repo>/`).

## Mettre à jour les aides

**Tout le contenu factuel est dans [`src/content/site.ts`](src/content/site.ts)** (dispositifs par région, FAQ régionales, chiffres, dates d'arrêt des activités dans `CLOSURE`). Il alimente à la fois les pages, le JSON-LD et les fichiers `llms*.txt`. Après une revue des sources officielles, modifier les textes **et** `SITE.verifiedISO` / `SITE.verifiedLabel` (date affichée et `dateModified`), puis pousser sur `main`.

## Déploiement

Le workflow [`.github/workflows/pages.yml`](../.github/workflows/pages.yml) construit `site/` et publie sur GitHub Pages à chaque push sur `main` touchant `site/`.
Réglages à faire une fois : *Settings → Pages → Source : GitHub Actions*, puis *Custom domain* `www.primes-services.be` (+ DNS : `CNAME www → <org>.github.io`).
