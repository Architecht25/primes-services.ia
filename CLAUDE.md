# CLAUDE.md — Primes Services IA

Fichier de contexte pour Claude Code. Lire avant toute session.

## Domaine métier

Site web vitrine et générateur de leads pour **Primes Services**, activité de conseil en primes et subsides de rénovation en Belgique (Wallonie, Flandre, Bruxelles-Capitale). Malgré son nom, l'application n'embarque plus de fonctionnalité IA active — le chatbot et le moteur de suggestions IA d'origine ont été retirés (voir Points d'attention).

Fonctions réelles aujourd'hui :
- Pages de contenu SEO/géo-ciblées par région (`/regions/wallonie`, `/regions/flandre`, `/regions/bruxelles`) avec villes, programmes de primes et FAQ locales
- Pages de simulation par région et par type d'aide (primes / prêts)
- Formulaire de contact unique (`ContactSubmission`), avec anti-bot (honeypot + délai de soumission + Cloudflare Turnstile) et notification email à l'équipe
- Passerelle vers **Ren0vate** (`RENOVATE_BASE_URL`) : page d'information et tracking de clics (`RenovateClick`), sans intégration self-service directe
- Back-office admin (`/admin`) : liste/export des contacts, dashboard de stats, monitoring sécurité (logs, scan, health check)

**Régions couvertes :** Wallonie, Flandre, Bruxelles.

## Stack technique

| Composant | Version |
|-----------|---------|
| Ruby | 3.3.9 |
| Rails | ~> 8.0.3 (résolu 8.0.5.1) |
| Bundler | 2.6.9 |
| DB (dev + prod) | PostgreSQL (pas de SQLite) |
| Assets | Propshaft + Importmap-rails |
| Frontend | Turbo-rails + Stimulus-rails |
| CSS | Tailwind CSS (`tailwindcss-rails`) — seul repo de la famille Primes-Services à ne pas utiliser Bootstrap |
| JSON | Jbuilder |
| Queue/Cache/Cable | Solid Queue + Solid Cache + Solid Cable |
| Auth admin | Session maison (`AdminAuthentication` concern), pas de Devise |
| Sécurité | Rack::Attack (throttling), Cloudflare Turnstile (anti-bot contact), Sentry (erreurs) |
| Storage | AWS S3 (Active Storage) — pas de Cloudinary |
| Emails | Resend (SMTP) |
| Analytics | Google Analytics |
| Déploiement | Heroku (actif) ; config Kamal présente mais non branchée |

## Commandes essentielles

```bash
# Développement
bin/dev                          # Démarre Puma + Tailwind watcher (Procfile.dev)
bin/rails db:create db:migrate   # Base de données
bin/rails db:seed                # Seeds

# Tests
bin/rails test                   # Tests unitaires (models/controllers/services/mailers/helpers/integration)
bin/rails test:system            # Tests système (Capybara + Selenium)

# Qualité
bin/rubocop                      # Linting (rubocop-rails-omakase)
bin/brakeman --no-pager --format text -w2   # Sécurité (seuil confidence medium/high, cf. CI)

# Production (Heroku)
git push heroku main             # Déploiement manuel (voir aussi CI/CD ci-dessous)
heroku logs --tail --app primes-services-ia
heroku run rails console --app primes-services-ia
```

## CI/CD

`.github/workflows/ci.yml` — pipeline la plus mature de la famille de repos Primes-Services (seule avec déploiement Heroku piloté par la CI) :
1. **Job `test`** (push/PR sur `main`/`develop`) : Postgres 16 en service, `bin/rails db:schema:load`, `bin/rails test`, puis `bin/brakeman -w2`
2. **Job `deploy`** : déclenché uniquement si `test` passe **et** push sur `main` → `git push heroku main` via `HEROKU_API_KEY` (secret GitHub)

Toute régression de test ou finding Brakeman medium/high bloque donc le déploiement automatique — ne pas contourner ce garde-fou.

## Architecture

```
app/
  controllers/
    pages_controller.rb          # Accueil, about, simulation générique, simulation par région/type
    regions_controller.rb        # Pages SEO régionales (contenu statique en dur : villes, primes, FAQ)
    contacts_controller.rb       # Formulaire de contact unique + anti-bot (honeypot/délai/Turnstile)
    application_controller.rb    # Redirection apex → www (canonicalisation SEO)
    admin/
      base_controller.rb         # Layout admin + AdminAuthentication
      sessions_controller.rb     # Login admin (session, pas Devise)
      dashboard_controller.rb    # Stats contacts/renovate/sécurité/système
      contacts_controller.rb     # Liste/recherche/export CSV/actions groupées
      security_controller.rb     # Logs, scan, health check (DB/cache/storage/SSL/headers)
  models/
    contact_submission.rb        # Modèle STI de base — validations, scopes, cycle de vie (pending→processed/completed)
    particulier_contact.rb       # Sous-types STI — conservés UNIQUEMENT pour compat historique (colonne `type`)
    acp_contact.rb                 (voir Modèle de données clé)
    entreprise_immo_contact.rb
    entreprise_comm_contact.rb
    renovate_click.rb             # Tracking clics/redirections vers Ren0vate
    security_log.rb               # Journal des événements de sécurité (login admin, etc.)
  services/
    turnstile_verification_service.rb  # Vérification serveur du token Cloudflare Turnstile (fail-open si clé absente)
    contact_export_service.rb          # Export CSV des contacts, neutralise l'injection de formule (=, +, -, @, tab, CR)
    security_monitor_service.rb        # Health check + rapport de sécurité pour l'admin
    geolocation_service.rb             # Enrichissement géo des contacts par région/code postal
    pwa_cache_service.rb               # Listes d'URLs à mettre en cache pour le mode offline PWA
    node_mailer_service.rb             # MORT — voir Points d'attention
  jobs/
    application_job.rb           # Aucun job métier custom actuellement
  mailers/
    contact_mailer.rb            # Notification admin à la création d'un contact (deliver_later)
```

## Modèle de données clé

```
ContactSubmission (STI, colonne `type`)
├── ParticulierContact       ) sous-types conservés pour compat historique uniquement —
├── AcpContact                ) le formulaire actuel crée toujours des ContactSubmission
├── EntrepriseImmoContact      ) directement (plus de formulaires spécialisés par profil)
└── EntrepriseCommContact    )

RenovateClick   — tracking clic/redirection vers Ren0vate (profile, region, source_page, event_type)
SecurityLog     — événements de sécurité (event_type, severity, ip_address, details jsonb)
```

- `ContactSubmission` : formulaire de contact unique et générique (`name`, `email`, `phone`, `region`, `message`), avec `status` (pending/processed/completed/archived), `read_at`, honeypot/anti-bot géré au niveau contrôleur. Champs `address`/`city`/`postal_code`/`surface_area`/`income_range`/`project_scale`/`target_market` hérités des anciens formulaires spécialisés par profil, plus renseignés côté formulaire actuel.
- **Tables mortes en base** (résidus de la fonctionnalité IA retirée, non nettoyées) : `ai_insights`, `calculations`, `primes`, `page_visits` — présentes dans `db/schema.rb` mais aucun modèle Rails ni contrôleur ne les référence.

## Conventions

- **Locale** : pas de scope `/:locale` dans les routes (contrairement à Ren0vate) — contenu FR par défaut, avec quelques mentions NL dans le contenu SEO régional.
- **Auth admin** : session maison (`AdminAuthentication` concern), identifiants via `ADMIN_USERNAME`/`ADMIN_PASSWORD` — pas de modèle `User`, pas de Devise sur ce repo.
- **STI** : ne pas créer de nouveaux sous-types de `ContactSubmission` — toute nouvelle demande passe par la classe de base.
- **Sécurité formulaire contact** : toute modification du formulaire doit préserver les 3 couches anti-bot (honeypot `website`, délai minimum `MIN_SUBMISSION_DELAY`, Turnstile) — ne pas les retirer même en dev.
- **CSP** : nonce généré par requête sur `script-src` ; `style-src` autorise `unsafe_inline` (Tailwind compilé en statique mais vues/Turbo utilisent des styles inline) ; `frame-src` autorise explicitement `challenges.cloudflare.com` pour le widget Turnstile.
- **Rubocop** : `rubocop-rails-omakase`, pas de règle custom ajoutée dans `.rubocop.yml`.
- **Migrations/Rails** : conventions standard Rails, rien de spécifique observé (pas de règle d'équipe documentée dans le repo au-delà du linting).

## Variables d'environnement Heroku

```
DATABASE_URL              # PostgreSQL Heroku
APP_HOST                  # Host canonique (www.primes-services.be)
SMTP_ADDRESS/PORT/DOMAIN/USERNAME/PASSWORD   # Resend SMTP
TEAM_EMAIL                # Adresse équipe (notifications)
GOOGLE_ANALYTICS_ID       # Analytics
ADMIN_USERNAME/PASSWORD   # Accès /admin — obligatoire, pas de fallback
TURNSTILE_SITE_KEY/SECRET_KEY   # Anti-bot formulaire contact (Cloudflare)
DEFAULT_REGION / SUPPORTED_REGIONS   # wallonie,flandre,bruxelles
RENOVATE_BASE_URL         # Lien vers Ren0vate
SENTRY_DSN                # Monitoring erreurs (actif seulement si renseigné, prod only)
AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY / AWS_REGION / AWS_BUCKET   # Active Storage S3
HEROKU_API_KEY            # Secret GitHub Actions pour le job deploy de la CI (pas une var Heroku)
```

## Points d'attention

- **Fonctionnalité IA retirée, reliquats non nettoyés** : le chatbot et le moteur de suggestions IA d'origine ont été supprimés du code (`app/views/ai/*.erb` retiré), mais plusieurs traces subsistent :
  - `Gemfile` garde `httparty` commenté "HTTP requests for external APIs (Anthropic/Claude)" — plus aucun appel HTTP IA dans le code
  - `.env` (réel, pas `.env.example`) contient encore `ANTHROPIC_API_KEY`, `AI_ASSISTANT_NAME`, `AI_CACHE_*`, `CHAT_ANALYTICS_ENABLED`, `RENOVATE_API_KEY` — absents de `.env.example`, donc non documentés pour un nouvel environnement
  - `db/schema.rb` garde les tables `ai_insights`, `calculations`, `primes`, `page_visits` sans modèle ni contrôleur correspondant
  - `README.md` est **obsolète** : il décrit `AiChatbotService`, `NaturalLanguageProcessor`, `EmailService`, des formulaires spécialisés par profil (`/contacts/particulier`, `/contacts/acp`...) et des routes `/ai/*` qui n'existent plus dans le code actuel — ne pas s'y fier pour l'architecture réelle, se référer à ce fichier et au code.
  - Traiter ces reliquats comme de la **dette à nettoyer**, pas comme une base à réactiver sans réflexion produit sur le retour de l'IA.
- **Kamal configuré mais mort** : `.kamal/`, `config/deploy.yml` présents avec IP placeholder (`192.168.0.1`), host `app.example.com`, jamais adaptés au projet réel — le déploiement effectif passe exclusivement par Heroku (Procfile + CI). Ne pas supposer que Kamal est utilisable en l'état.
- **`NodeMailerService` mort** : `app/services/node_mailer_service.rb` appelle un script `emailer/mailer.js` **qui n'existe pas dans le repo**, pensé pour contourner les Security Defaults Azure AD d'un ancien setup SMTP Office 365. Le service n'est appelé nulle part — l'envoi d'email réel passe par `ActionMailer` + Resend SMTP (`config/environments/production.rb`, `smtp.resend.com` par défaut). Le `.env` réel documente encore l'ancien SMTP Office 365 (`SMTP_HOST=smtp.office365.com`), incohérent avec `.env.example` (Resend) — ne pas se fier au `.env` local comme référence de la config de prod.
- **Routes API sans contrôleur** : `config/routes.rb` déclare `namespace :api` avec `geolocation#detect_by_ip`/`#reverse` et `cache#essential_data`/`#store_form_draft`/etc., mais **aucun contrôleur `Api::*` n'existe** dans `app/controllers` — ces routes lèveraient une erreur si elles étaient appelées. À corriger ou supprimer plutôt qu'à considérer comme fonctionnelles.
- **Sécurité/observabilité — repo de référence de la famille Primes-Services** : Sentry, Rack::Attack, Cloudflare Turnstile, AWS S3, honeypot + anti-bot temporisé sur le formulaire de contact, neutralisation d'injection de formule CSV à l'export. C'est le repo le plus avancé sur ce plan (Ren0vate excepté, qui a rattrapé Sentry + Rack::Attack récemment) — s'en inspirer pour les autres apps de la famille plutôt que l'inverse.
- **Pas de gestion multilingue** de type `/:locale` — si une internationalisation FR/NL structurée est nécessaire un jour, s'inspirer du pattern Ren0vate plutôt que de le réinventer.
