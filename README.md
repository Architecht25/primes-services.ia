# Primes Services IA

Site marketing et de génération de leads pour **Primes-Services** : il aide les
particuliers, les copropriétés (ACP) et les entreprises à identifier les primes et
prêts à la rénovation en Belgique, dans les trois régions (Wallonie, Flandre,
Bruxelles-Capitale).

Il comprend :

- des **calculateurs de primes** et pages de prêts par région (`/simulation/:region`,
  `/simulation/:region/primes`, `/simulation/:region/prets`)
- un **formulaire de contact** à quatre profils (particulier, ACP, entreprise
  immobilière, entreprise commerciale), protégé par Cloudflare Turnstile
- un **espace d'administration** (`/admin`) : contacts, export, actions groupées,
  supervision de sécurité
- une **PWA** (manifeste, service worker, page hors ligne)

## Modèle de données

Les soumissions de contact utilisent l'héritage de table unique (STI) sur
`contact_submissions` :

```
ContactSubmission (base)
├── ParticulierContact
├── AcpContact
├── EntrepriseImmoContact
└── EntrepriseCommContact
```

Autres tables : `renovate_clicks` (clics sortants), `security_logs`, `page_visits`,
ainsi que `primes`, `calculations` et `ai_insights`. Les tables `solid_*` servent à
Solid Queue, Solid Cache et Solid Cable.

## Services

```
app/services/
├── contact_export_service.rb       # export des contacts
├── geolocation_service.rb          # détection de la région (IP, géocodage inverse)
├── node_mailer_service.rb          # envoi d'emails
├── pwa_cache_service.rb            # données et brouillons pour le cache PWA
├── security_monitor_service.rb     # supervision et scan de sécurité
└── turnstile_verification_service.rb  # vérification Cloudflare Turnstile
```

## Routes principales

| Route | Rôle |
|-------|------|
| `/` | page d'accueil |
| `/contacts/new`, `POST /contacts` | formulaire de contact |
| `/regions/:region`, `/regions/:region/villes` | pages région et villes |
| `/pages/about`, `/pages/simulation`, `/pages/renovate` | pages statiques |
| `/admin` | administration (connexion `admin/login`) |
| `/api/geolocation/detect_by_ip`, `/api/geolocation/reverse` | géolocalisation |
| `/api/cache/*` | données essentielles et brouillons de formulaire (PWA) |
| `/ping`, `/up` | health checks |

## Stack

- Ruby 3.3.9, Rails 8.0.5
- PostgreSQL
- Hotwire via importmap, Propshaft, Tailwind CSS
- Solid Queue, Solid Cache, Solid Cable (sans Redis)
- Active Storage sur Amazon S3
- Sentry pour le suivi des erreurs
- HTTParty pour les appels à l'API Anthropic (Claude)

## Installation

```bash
bundle install
bin/rails db:create db:migrate db:seed
bin/dev                  # serveur + Tailwind (Procfile.dev)
```

## Variables d'environnement

Lues par le code :

| Variable | Usage |
|----------|-------|
| `DATABASE_URL` | connexion PostgreSQL |
| `ADMIN_USERNAME`, `ADMIN_PASSWORD` | accès à l'administration |
| `TURNSTILE_SITE_KEY`, `TURNSTILE_SECRET_KEY` | anti-spam du formulaire (sans clé, le contrôle est désactivé) |
| `SMTP_HOST`, `SMTP_PORT`, `SMTP_ADDRESS`, `SMTP_DOMAIN`, `SMTP_USERNAME`, `SMTP_PASSWORD`, `MAILER_FROM` | envoi d'emails |
| `APP_HOST`, `APP_HOST_URL` | URL de l'application (liens dans les emails) |
| `AWS_REGION`, `AWS_BUCKET`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` | stockage S3 |
| `SENTRY_DSN` | suivi des erreurs |
| `RAILS_MAX_THREADS`, `JOB_CONCURRENCY`, `RAILS_LOG_LEVEL`, `PORT` | réglages d'exécution |

## Tests

```bash
bin/rails test           # tests du dossier test/ (contrôleurs)
```

## Déploiement

- `Dockerfile` et `config/deploy.yml` pour Kamal. Le `Procfile` ne définit que le
  processus `web`. Le champ `image` de `config/deploy.yml` est encore un placeholder
  (`your-user/primes_services_ia`) et les serveurs ne sont pas renseignés : à compléter
  avant le premier `kamal setup`.
