# Guide d'Identité Visuelle — Primes Services

## Palette de Couleurs

Cette palette de 5 couleurs harmonisées définit l'identité visuelle de Primes Services.

### 🔵 Bleu Marine — Couleur Principale
**Hex:** `#1A3C5E`
**Tailwind:** `primary-600`

**Usage:**
- Titres et en-têtes principaux
- Navigation et header
- Boutons d'action principaux (CTA)
- Éléments institutionnels
- Footer

**Évoque:** Confiance, sérieux, professionnalisme, stabilité institutionnelle

**Exemples d'utilisation:**
```html
<h1 class="text-primary-600">Titre principal</h1>
<button class="bg-primary-600 hover:bg-primary-700 text-white">Action</button>
<nav class="bg-primary-600">...</nav>
```

---

### 🟢 Vert Émeraude — Couleur Secondaire
**Hex:** `#2E7D52`
**Tailwind:** `secondary-500`

**Usage:**
- Boutons secondaires et CTA alternatifs
- Icônes principales
- Sections thématiques sur l'énergie et la durabilité
- Badges et labels de rénovation
- Illustrations et graphiques

**Évoque:** Énergie, durabilité, rénovation écologique, croissance

**Exemples d'utilisation:**
```html
<button class="bg-secondary-500 hover:bg-secondary-600 text-white">En savoir plus</button>
<div class="border-l-4 border-secondary-500">...</div>
<svg class="text-secondary-500">...</svg>
```

---

### ✅ Vert Clair — Accents & Highlights
**Hex:** `#4DB885`
**Tailwind:** `accent-400`

**Usage:**
- Accents visuels, icônes de succès
- Highlights et éléments interactifs
- Badges de succès et validation
- Indicateurs positifs
- Liens au survol

**Évoque:** Succès, validation, optimisme, accessibilité

**Exemples d'utilisation:**
```html
<span class="bg-accent-400 text-white px-3 py-1 rounded-full">Éligible</span>
<svg class="text-accent-400"><!-- icône check --></svg>
<a href="#" class="text-accent-500 hover:text-accent-600">Lien</a>
```

---

### 🟡 Ambre — Accentuation & Alertes
**Hex:** `#E8A020`
**Tailwind:** `amber-400`

**Usage:**
- Accentuation et mise en avant
- Alertes informatives (non critiques)
- Chiffres clés et statistiques importantes
- Éléments de primes et aides financières
- Call-to-action secondaires

**Évoque:** Attention, valeur, opportunité, importance

**Exemples d'utilisation:**
```html
<div class="bg-amber-50 border-l-4 border-amber-400 p-4">Alerte importante</div>
<span class="text-amber-400 font-bold text-4xl">5 500 €</span>
<button class="border-2 border-amber-400 text-amber-600 hover:bg-amber-50">Découvrir</button>
```

---

### ⚪ Gris Perle — Fond & Neutralité
**Hex:** `#F4F7FA`
**Tailwind:** `pearl-50`

**Usage:**
- Fond de page principal
- Sections alternées pour créer du rythme
- Arrière-plans de cartes
- Espaces de respiration visuelle

**Évoque:** Clarté, propreté, neutralité, professionnalisme

**Exemples d'utilisation:**
```html
<body class="bg-pearl-50">...</body>
<section class="bg-pearl-50 py-12">...</section>
<div class="bg-white border border-pearl-200 rounded-lg">Carte</div>
```

---

## Combinaisons Recommandées

### 🎯 Héros / Hero Section
```html
<section class="bg-gradient-to-br from-primary-600 to-primary-800 text-white">
  <h1 class="text-4xl font-bold">Titre impactant</h1>
  <p class="text-primary-100">Description claire</p>
  <button class="bg-amber-400 hover:bg-amber-500 text-primary-900">Action principale</button>
</section>
```

### 📊 Cartes de Primes
```html
<div class="bg-white rounded-lg shadow-lg border-t-4 border-secondary-500 p-6">
  <h3 class="text-primary-700 text-xl font-semibold">Titre de la prime</h3>
  <p class="text-gray-600">Description</p>
  <div class="text-amber-400 text-3xl font-bold">Jusqu'à 5 000 €</div>
  <button class="bg-accent-400 hover:bg-accent-500 text-white">Vérifier mon éligibilité</button>
</div>
```

### 🔔 Messages d'Information
```html
<!-- Info -->
<div class="bg-accent-50 border-l-4 border-accent-400 p-4">
  <p class="text-accent-800">Information positive</p>
</div>

<!-- Attention -->
<div class="bg-amber-50 border-l-4 border-amber-400 p-4">
  <p class="text-amber-800">Information importante</p>
</div>

<!-- Standard -->
<div class="bg-pearl-100 border-l-4 border-primary-400 p-4">
  <p class="text-primary-800">Information neutre</p>
</div>
```

### 🎨 Boutons
```html
<!-- Principal -->
<button class="bg-primary-600 hover:bg-primary-700 text-white px-6 py-3 rounded-lg font-semibold shadow-md">
  Action principale
</button>

<!-- Secondaire -->
<button class="bg-secondary-500 hover:bg-secondary-600 text-white px-6 py-3 rounded-lg font-semibold">
  Action secondaire
</button>

<!-- Accent -->
<button class="bg-accent-400 hover:bg-accent-500 text-white px-6 py-3 rounded-lg font-semibold">
  Valider
</button>

<!-- Attention -->
<button class="bg-amber-400 hover:bg-amber-500 text-primary-900 px-6 py-3 rounded-lg font-semibold">
  Découvrir les primes
</button>

<!-- Outline -->
<button class="border-2 border-primary-600 text-primary-600 hover:bg-primary-50 px-6 py-3 rounded-lg font-semibold">
  En savoir plus
</button>
```

---

## Hiérarchie Typographique avec Couleurs

### Titres
- **H1:** `text-primary-700` ou `text-white` sur fond coloré
- **H2:** `text-primary-600`
- **H3:** `text-primary-500` ou `text-secondary-600`
- **H4-H6:** `text-gray-700` ou `text-primary-400`

### Textes
- **Corps principal:** `text-gray-700` ou `text-gray-800`
- **Texte secondaire:** `text-gray-600`
- **Texte subtil:** `text-gray-500`
- **Liens:** `text-accent-500 hover:text-accent-600`

---

## Accessibilité et Contraste

### ✅ Combinaisons Accessibles (WCAG AA)

**Texte sur fond clair:**
- `text-primary-600` sur `bg-white` ✓
- `text-primary-700` sur `bg-pearl-50` ✓
- `text-secondary-600` sur `bg-white` ✓
- `text-gray-700` sur `bg-white` ✓

**Texte sur fond foncé:**
- `text-white` sur `bg-primary-600` ✓
- `text-white` sur `bg-secondary-500` ✓
- `text-primary-900` sur `bg-amber-400` ✓

**Texte sur fond coloré:**
- `text-primary-800` sur `bg-amber-50` ✓
- `text-accent-800` sur `bg-accent-50` ✓

---

## Migration Progressive

Pour migrer votre code existant vers la nouvelle palette:

1. **Remplacer les blues génériques:**
   - `blue-600` → `primary-600`
   - `blue-700` → `primary-700`

2. **Remplacer les greens:**
   - `green-500` → `secondary-500`
   - `green-600` → `accent-400` (pour highlights)

3. **Remplacer les yellows/oranges:**
   - `yellow-500` → `amber-400`
   - `orange-500` → `amber-500`

4. **Optimiser les fonds:**
   - `bg-gray-50` → `bg-pearl-50`
   - `bg-gray-100` → `bg-pearl-100`

---

## Variables CSS Disponibles

En plus des classes Tailwind, vous pouvez utiliser directement les variables CSS:

```css
.custom-element {
  background-color: var(--color-marine);
  color: var(--color-emeraude);
  border-color: var(--color-highlight);
}

/* Alias disponibles */
--color-marine: #1A3C5E
--color-emeraude: #2E7D52
--color-highlight: #4DB885
--color-warning: #E8A020
--color-background: #F4F7FA
```

---

## Ressources Supplémentaires

- Configuration complète: [`app/assets/tailwind/application.css`](../app/assets/tailwind/application.css)
- Documentation Tailwind v4: https://tailwindcss.com
- Outil de vérification de contraste: https://webaim.org/resources/contrastchecker/

---

**Dernière mise à jour:** Mars 2026
**Version:** 1.0
