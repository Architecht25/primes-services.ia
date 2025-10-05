# 🚀 Primes Services IA - Assistant Spécialisé en Primes Belges

## 📋 Description

**Primes Services IA** est une plateforme intelligente d'assistance pour l'obtention de primes et subsides en Belgique. L'application utilise l'intelligence artificielle pour analyser automatiquement les profils utilisateurs et proposer les aides les plus pertinentes selon leur situation géographique et leurs besoins spécifiques.

## ✨ Fonctionnalités Principales

### 🤖 Intelligence Artificielle Intégrée
- **Chatbot conversationnel** spécialisé dans les primes belges
- **Analyse automatique** des profils utilisateurs
- **Suggestions personnalisées** selon la région et le type de projet
- **Détection de complexité** avec redirection vers experts

### 📝 Formulaires Spécialisés (STI Pattern)
- **Particuliers** : Propriétaires de maisons et appartements
- **ACP (Associations de Copropriétaires)** : Syndics et copropriétés
- **Entreprises Immobilières** : Promoteurs, constructeurs, gestionnaires
- **Entreprises Commerciales** : PME, startups, industries

### 🏛️ Support Multi-Régional
- **Wallonie** : Primes habitation, isolation, chauffage
- **Flandre** : Mijn VerbouwPremie, aides flamandes
- **Bruxelles-Capitale** : Renolution, Prime Energie

### 🎯 Services Intelligents
- **GeolocationService** : Spécificités locales et autorités compétentes
- **EmailService** : Confirmations automatiques et analyses IA
- **NaturalLanguageProcessor** : Analyse d'intention et extraction d'entités

## 🛠️ Architecture Technique

### Stack Principal
- **Rails 8.0** avec PostgreSQL
- **Tailwind CSS** pour le design responsive
- **Stimulus Controllers** pour l'interactivité
- **PWA Ready** (Progressive Web App)

### Modèles de Données
```ruby
# STI (Single Table Inheritance)
ContactSubmission (base)
├── ParticulierContact
├── AcpContact
├── EntrepriseImmoContact
└── EntrepriseCommContact

# IA et Conversations
AiConversation
```

### Services Métier
```ruby
app/services/
├── ai_chatbot_service.rb          # Orchestration IA principale
├── natural_language_processor.rb  # Analyse NLP
├── email_service.rb              # Communications automatiques
└── geolocation_service.rb        # Données géographiques
```

## 🚀 Installation

### Prérequis
- Ruby 3.3.5
- Rails 8.0
- PostgreSQL
- Node.js (pour les assets)

### Configuration
```bash
# Cloner le repository
git clone https://github.com/Architecht25/primes-services.ia.git
cd primes-services.ia

# Installer les dépendances
bundle install
yarn install

# Configuration base de données
rails db:create
rails db:migrate
rails db:seed

# Démarrer l'application
bin/dev
```

### Variables d'environnement
```env
# Configuration IA (optionnel pour développement)
OPENAI_API_KEY=your_openai_key_here

# Base de données
DATABASE_URL=postgresql://username:password@localhost/primes_services_ia
```

## 📱 Utilisation

### Interface Utilisateur
1. **Sélection de profil** sur `/contacts/new`
2. **Formulaire adapté** selon le type d'utilisateur
3. **Analyse IA automatique** et suggestions de primes
4. **Suivi par email** avec récapitulatif personnalisé

### API Endpoints
```ruby
# Formulaires de contact
GET  /contacts/new           # Sélection profil
GET  /contacts/particulier   # Formulaire particuliers
GET  /contacts/acp          # Formulaire copropriétés
POST /contacts              # Soumission formulaire
GET  /contacts/:id          # Résultats et suggestions

# IA Chatbot
GET  /ai/chat              # Interface de chat
POST /ai/send_message      # Envoi de message
GET  /ai/suggestions       # Suggestions contextuelles
```

## 🎯 Fonctionnalités par Profil

### 👤 Particuliers
- Type de logement et travaux souhaités
- Analyse des revenus pour calcul des primes
- Suggestions d'isolation, chauffage, rénovation
- Estimation budgétaire personnalisée

### 🏢 Copropriétés (ACP)
- Nombre de logements et type d'immeuble
- Travaux collectifs (façade, toiture, chauffage)
- Budget voté et urgence des travaux
- Coordination avec syndic professionnel

### 🏗️ Entreprises Immobilières
- Activité (promotion, construction, gestion)
- Échelle des projets et marché cible
- Certifications environnementales
- Optimisation fiscale et juridique

### 🏭 Entreprises Commerciales
- Secteur d'activité et taille d'entreprise
- Type d'investissement (R&D, équipement, digital)
- Marchés cibles (B2B, B2C, export)
- Aides innovation et développement

## 🧠 Intelligence Artificielle

### Analyse Automatique
```ruby
# Exemple d'utilisation du service IA
contact = ParticulierContact.create(...)
ai_service = AiChatbotService.new
suggestions = ai_service.generate_personalized_suggestions(contact)

# Résultat : liste de primes pertinentes avec eligibilité
```

### NLP (Natural Language Processing)
- **Extraction d'intention** : Identifier le type de demande
- **Reconnaissance d'entités** : Région, type de travaux, budget
- **Score de confiance** : Fiabilité de l'analyse
- **Contexte conversationnel** : Historique des échanges

## 📊 Base de Données

### Tables Principales
```sql
-- Contacts avec STI
contact_submissions (type, name, email, region, ...)

-- Conversations IA
ai_conversations (session_id, messages, status, ...)

-- Données métier (optionnel)
primes, calculations, ai_insights
```

## 🔧 Développement

### Architecture MVC
```
app/
├── controllers/
│   ├── ai_controller.rb           # Endpoints IA
│   ├── contacts_controller.rb     # Gestion formulaires
│   └── pages_controller.rb        # Pages statiques
├── models/
│   ├── contact_submission.rb      # Modèle base STI
│   ├── particulier_contact.rb     # Spécialisations STI
│   └── ai_conversation.rb         # Conversations IA
├── services/
│   └── [services métier]
└── views/
    ├── contacts/forms/            # Formulaires spécialisés
    ├── shared/                    # Composants partagés
    └── layouts/                   # Layout principal
```

## 🌐 Déploiement

### Production avec Kamal
```bash
# Configuration dans config/deploy.yml
kamal setup    # Premier déploiement
kamal deploy   # Déploiements suivants
```

## 📈 Roadmap

### Version 1.1 (Q1 2026)
- [ ] Intégration APIs officielles (SPW, VEA, Bruxelles Environnement)
- [ ] Calculs automatiques de montants de primes
- [ ] Dashboard administrateur

### Version 1.2 (Q2 2026)
- [ ] Application mobile (React Native)
- [ ] Notifications push
- [ ] Intégration avec Ren0vate

## 👥 Contribution

### Développement Local
1. Fork le repository
2. Créer une branche feature (`git checkout -b feature/amazing-feature`)
3. Commit les changements (`git commit -m 'Add amazing feature'`)
4. Push la branche (`git push origin feature/amazing-feature`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence MIT.

## 🤝 Support

- **Email** : contact@architecht25.com
- **GitHub Issues** : Pour les bugs et feature requests

### Architecture 25
Développé avec ❤️ par l'équipe **Architecture 25**
Spécialistes en solutions numériques innovantes pour le secteur de la construction et des primes énergétiques.

---

**Made in Belgium 🇧🇪 | Powered by Rails 🚂 | Enhanced by AI 🤖**
