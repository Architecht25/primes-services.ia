# Guide Local SEO / GEO SEO - Primes Services IA

## 🎯 Stratégie Local SEO Implémentée

### 1. Structure géographique
- ✅ **3 pages régionales principales** : Wallonie, Flandre, Bruxelles
- ✅ **8+ pages par ville** : Liège, Charleroi, Anvers, Gand, etc.
- ✅ **URLs SEO-friendly** : `/regions/wallonie`, `/regions/flandre/anvers`
- ✅ **Navigation géographique** intégrée au layout

### 2. Schema.org Local Business
- ✅ **LocalBusiness** pour chaque région
- ✅ **Service schema** pour chaque ville
- ✅ **Coordonnées géographiques** précises
- ✅ **Zone de service** définie (rayon 100km)
- ✅ **Contact local** par région

### 3. Meta tags géographiques
- ✅ **geo.region** : BE (Belgique)
- ✅ **geo.placename** : Belgique
- ✅ **geo.position** : coordonnées Bruxelles
- ✅ **ICBM** : format standard géolocalisation
- ✅ **language** : fr-BE

### 4. Contenu géo-localisé
- ✅ **Titles** : "Primes Wallonie", "Subsides Anvers"
- ✅ **Meta descriptions** contextuelles par région
- ✅ **Keywords géographiques** : "primes liège", "subsides gand"
- ✅ **Contenu spécifique** par région et ville

## 🗺️ Mots-clés géographiques ciblés

### Mots-clés primaires régionaux
- **"primes wallonie"** → page région Wallonie
- **"subsides flandre"** → page région Flandre
- **"primes bruxelles"** → page région Bruxelles

### Mots-clés longue traîne par ville
- **"primes isolation liège"** → page ville Liège
- **"subsides énergétiques gand"** → page ville Gand
- **"prime rénovation ixelles"** → page ville Ixelles

### Mots-clés programmes locaux
- **"Prime Habitation wallonie"**
- **"Mijn VerbouwPremie flandre"**
- **"Renolution bruxelles"**

## 📊 Structure des URLs Local SEO

```
/                              # Accueil national
├── /regions/wallonie          # Page région Wallonie
│   ├── /regions/wallonie/liege        # Ville Liège
│   ├── /regions/wallonie/charleroi    # Ville Charleroi
│   └── /regions/wallonie/namur        # Ville Namur
├── /regions/flandre           # Page région Flandre
│   ├── /regions/flandre/anvers        # Ville Anvers
│   ├── /regions/flandre/gand          # Ville Gand
│   └── /regions/flandre/bruges        # Ville Bruges
└── /regions/bruxelles         # Page région Bruxelles
    ├── /regions/bruxelles/ixelles     # Commune Ixelles
    └── /regions/bruxelles/uccle       # Commune Uccle
```

## 🔧 Helpers Local SEO

### Utilisation dans les vues

```erb
<!-- Schema.org pour région -->
<%= region_local_business_schema('wallonie') %>

<!-- Schema.org pour ville -->
<%= city_service_schema('Liège', 'wallonie') %>

<!-- Meta tags géographiques -->
<% content_for :keywords, geo_keywords('wallonie', ['isolation', 'chauffage']) %>
<% content_for :description, geo_meta_description('wallonie', 'contact') %>

<!-- Breadcrumbs géographiques -->
<%= breadcrumb_schema(geo_breadcrumbs('wallonie', 'Liège', 'Contact')) %>

<!-- URL canonique géographique -->
<% content_for :canonical, geo_canonical_url('wallonie', '/contact') %>
```

### Helpers disponibles

1. **`region_local_business_schema(region)`** → Schema LocalBusiness
2. **`city_service_schema(city, region)`** → Schema Service ville
3. **`geo_keywords(region, additional)`** → Mots-clés géographiques
4. **`geo_meta_description(region, type)`** → Description géolocalisée
5. **`geo_breadcrumbs(region, city, page)`** → Breadcrumbs géographiques
6. **`detect_region_from_postal_code(code)`** → Détection automatique
7. **`geo_canonical_url(region, suffix)`** → URL canonique

## 📈 Impact SEO attendu

### Visibilité géographique
- **Wallonie** : "primes wallonie", "subsides SPW", "aide rénovation wallonie"
- **Flandre** : "premies vlaanderen", "subsidies flandre", "VEA steun"
- **Bruxelles** : "primes bruxelles", "renolution", "homegrade"

### Longue traîne locale
- **Liège** : "primes isolation liège", "subsides chauffage liège"
- **Anvers** : "premies antwerpen", "subsidies anvers"
- **Ixelles** : "prime énergie ixelles", "aide rénovation ixelles"

### Recherches vocales
- "Quelles primes à Liège ?"
- "Subsides disponibles Gand"
- "Aide rénovation près de moi"

## 🚀 Optimisations futures

### Court terme (2 semaines)
1. **Google My Business** pour chaque région
2. **Citations locales** sur annuaires belges
3. **Contenu local** : actualités par région

### Moyen terme (1 mois)
1. **Pages par code postal** (automatisées)
2. **Avis clients géolocalisés**
3. **Partenariats locaux** (liens entrants)

### Long terme (3 mois)
1. **Version multilingue** (NL pour Flandre)
2. **App mobile** géolocalisée
3. **Local Pack** Google dominé

## 🔍 Suivi et analytics

### KPIs Local SEO
- **Positions** sur "primes [ville]"
- **Trafic organique** par région
- **Conversions** géolocalisées
- **Recherches "près de moi"**

### Outils recommandés
- **Google Search Console** : performance par région
- **Google Analytics** : segments géographiques
- **BrightLocal** : suivi positions locales
- **SEMrush** : mots-clés géographiques

## 💡 Conseils d'optimisation

### Contenu local
- Mentionner les **autorités locales** (SPW, VEA, Bruxelles Env.)
- Utiliser le **vocabulaire local** (primes vs premies)
- Référencer les **programmes spécifiques** par région
- Ajouter des **témoignages géolocalisés**

### Technical SEO
- **Vitesse de chargement** optimisée par région
- **Données structurées** complètes
- **Navigation faceted** par géolocalisation
- **AMP** pour recherches mobiles locales

### Link Building local
- **Annuaires régionaux** : Wallonie Export, Flanders Investment
- **Médias locaux** : La Libre, Het Laatste Nieuws, RTBF
- **Institutions** : SPW, VEA, Bruxelles Environnement
- **Partenaires** : architectes, installateurs locaux
