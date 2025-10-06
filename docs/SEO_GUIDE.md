# Guide SEO - Primes Services IA

## 🎯 Meilleures pratiques SEO implémentées

### 1. Structure HTML sémantique
- ✅ Balises `<main>`, `<nav>`, `<footer>`
- ✅ Hiérarchie H1 → H6 logique
- ✅ Attribut `lang="fr-BE"` pour la langue

### 2. Meta tags optimisés
- ✅ Titles uniques par page (50-60 caractères)
- ✅ Meta descriptions personnalisées (150-160 caractères)
- ✅ Meta keywords contextuels
- ✅ URLs canoniques pour éviter le contenu dupliqué
- ✅ Meta robots pour contrôler l'indexation

### 3. Open Graph et réseaux sociaux
- ✅ Open Graph complet (titre, description, image, URL)
- ✅ Twitter Cards pour un affichage optimisé
- ✅ Locale définie (`fr_BE`)

### 4. Données structurées (Schema.org)
- ✅ LocalBusiness pour l'entreprise
- ✅ FAQPage pour les questions fréquentes
- ✅ Service pour les prestations
- ✅ SoftwareApplication pour l'IA
- ✅ BreadcrumbList pour la navigation

### 5. Fichiers SEO
- ✅ `robots.txt` optimisé avec directives claires
- ✅ Sitemap XML automatique via `sitemap_generator`
- ✅ Route `/sitemap.xml` configurée

### 6. Performance et Core Web Vitals
- ✅ PWA pour améliorer les métriques de performance
- ✅ Images optimisées avec icônes multiples
- ✅ CSS/JS via asset pipeline Rails

## 🛠️ Utilisation des helpers SEO

### Dans vos vues
```erb
<% content_for :title, seo_title("Ma page") %>
<% content_for :description, seo_description("Description de ma page") %>
<% content_for :keywords, seo_keywords('mot1', 'mot2', 'mot3') %>
<% content_for :canonical, seo_canonical(custom_url) %>

<!-- Schema.org FAQ -->
<%= faq_schema([
  { question: "Question ?", answer: "Réponse" }
]) %>

<!-- Schema.org Service -->
<%= service_schema("Nom du service", "Description") %>

<!-- Breadcrumbs -->
<%= breadcrumb_schema([
  ["Accueil", root_path],
  ["Services", services_path],
  ["Page actuelle", nil]
]) %>
```

## 📊 Commandes Rake SEO

### Générer le sitemap
```bash
# Génération du sitemap XML
rake seo:generate_sitemap

# Vérification de la configuration SEO
rake seo:check

# Soumission aux moteurs de recherche
rake seo:submit_sitemap
```

## 🎯 Mots-clés ciblés

### Mots-clés principaux
- **Primes belges** (volume élevé)
- **Subsides Wallonie** (localisation)
- **Primes Flandre** (localisation)
- **Assistant IA primes** (innovation)

### Longue traîne
- "Comment obtenir prime isolation Wallonie"
- "Calculateur prime énergétique Belgique"
- "Assistant intelligent subsides belges"
- "Primes rénovation Bruxelles 2025"

### Mots-clés techniques
- **Primes énergétiques** → isolation, chauffage, PV
- **Subsides rénovation** → travaux, amélioration
- **Accompagnement expert** → conseil, aide
- **IA conversationnelle** → chatbot, assistant

## 📈 KPIs SEO à suivre

### Trafic organique
- Impressions et clics Google Search Console
- Position moyenne des mots-clés ciblés
- Taux de clic (CTR) des pages principales

### Performance technique
- Core Web Vitals (LCP, FID, CLS)
- Vitesse de chargement (PageSpeed Insights)
- Indexation des pages (Search Console)

### Contenu
- Temps passé sur le site
- Taux de rebond
- Pages par session
- Conversions IA (utilisation du chatbot)

## 🚀 Prochaines étapes SEO

### Court terme (1-2 semaines)
1. **Installation des gems** : `bundle install` pour sitemap_generator
2. **Génération sitemap** : `rake seo:generate_sitemap`
3. **Test SEO** : `rake seo:check`
4. **Soumission Search Console** : soumettre sitemap.xml

### Moyen terme (1 mois)
1. **Google Analytics** : configurer suivi du trafic
2. **Search Console** : monitorer les performances
3. **Schema.org avancé** : ajouter plus de types de données
4. **Images optimisées** : WebP, alt texts, lazy loading

### Long terme (3 mois)
1. **Content marketing** : blog SEO sur les primes
2. **Liens entrants** : partenariats et mentions
3. **Multilingual** : versions NL/EN si pertinent
4. **Local SEO** : Google My Business, citations locales

## 🔧 Configuration par environnement

Le fichier `config/initializers/seo.rb` adapte automatiquement :
- URLs de base selon l'environnement
- Configuration Open Graph
- Paramètres du sitemap

En production, n'oubliez pas de :
1. Configurer le bon domaine dans `seo.rb`
2. Générer le sitemap après déploiement
3. Soumettre le sitemap à Google/Bing
4. Vérifier la propriété dans Search Console
