# 🛡️ Système d'Administration - Primes Services

## Accès au Panel Admin

L'interface d'administration est accessible via: **`/admin`**

### Authentification

Le système utilise HTTP Basic Authentication. Par défaut:
- **Username**: `admin`
- **Password**: `changeme123`

⚠️ **IMPORTANT**: Configurez vos propres identifiants en production via les variables d'environnement:

```bash
# Heroku
heroku config:set ADMIN_USERNAME=votre_username
heroku config:set ADMIN_PASSWORD=votre_mot_de_passe_securise

# Local (.env)
ADMIN_USERNAME=admin
ADMIN_PASSWORD=votre_mot_de_passe_securise
```

## Fonctionnalités

### 📊 Dashboard (`/admin`)
Vue d'ensemble complète avec:
- Statistiques des contacts (total, aujourd'hui, semaine, mois)
- Statistiques des conversations IA
- Analytics de visites
- État du système (base de données, uptime, etc.)
- Contacts par type
- Actions rapides

### 📧 Gestion des Contacts (`/admin/contacts`)
- **Liste complète** des contacts avec filtrage
- **Recherche** par nom, email, téléphone
- **Filtrage** par type de soumission
- **Export CSV** de tous les contacts
- **Marquage lu/non lu**
- **Vue détaillée** de chaque contact
- **Actions en masse** (à venir)

### 📈 Analytics (`/admin/analytics`)
Analyse complète du trafic:
- **Visites totales** et visiteurs uniques
- **Pages les plus visitées**
- **Visites par région** (Wallonie, Flandre, Bruxelles)
- **Sources de trafic** (referrers)
- **Données en temps réel**
- **Filtrage par période** (aujourd'hui, 7 jours, 30 jours)

### 🔒 Sécurité (`/admin/security`)
Monitoring de sécurité:
- **Health check** système (DB, disque, SSL)
- **Scan de sécurité** automatisé
- **Recommandations** de sécurité
- **Détection d'activités suspectes**
- **Logs de sécurité**
- **Vérification headers** de sécurité

## Modèles de Données

### PageVisit
Tracking des visites de pages:
```ruby
- visitor_id: string         # ID unique du visiteur
- page_path: string          # Chemin de la page visitée
- referrer: string           # Source de la visite
- user_agent: text           # Navigateur/OS
- ip_address: string         # Adresse IP
- user_region: string        # Région détectée
- device_type: string        # desktop/mobile/tablet
- session_id: string         # ID de session
- time_on_page: integer      # Temps passé (secondes)
```

### SecurityLog
Journalisation des événements de sécurité:
```ruby
- event_type: string         # Type d'événement
- severity: string           # critical/high/medium/low
- ip_address: string         # IP concernée
- user_agent: text           # User agent
- details: jsonb             # Détails JSON
- description: text          # Description
```

### ContactSubmission (mis à jour)
Nouveaux champs admin:
```ruby
- read_at: datetime          # Date de lecture
- ip_address: string         # IP du soumetteur
- user_agent: text           # Navigateur
- first_name: string         # Prénom
- last_name: string          # Nom
- property_type: string      # Type de propriété
- work_type: string          # Type de travaux
- submission_type: string    # Type de soumission
```

## Services

### AnalyticsService
Gestion des analytics:
```ruby
# Stats rapides
AnalyticsService.summary_stats

# Stats détaillées par période
AnalyticsService.detailed_stats('week')

# Temps réel
AnalyticsService.real_time_stats

# Tracking manuel
AnalyticsService.track_visit(request, '/path', user_region: 'wallonie')
```

### SecurityMonitorService
Monitoring de sécurité:
```ruby
# Health check rapide
SecurityMonitorService.health_check

# Rapport complet
SecurityMonitorService.full_report

# Scan de sécurité
SecurityMonitorService.run_security_scan

# Détection d'activités suspectes
SecurityMonitorService.detect_suspicious_activity
```

### ContactExportService
Export des contacts:
```ruby
# Export CSV
csv_data = ContactExportService.to_csv(contacts)

# Export JSON
json_data = ContactExportService.to_json(contacts)
```

## Routes Admin

```ruby
/admin                              # Dashboard principal
/admin/dashboard                    # Dashboard (alias)

# Contacts
/admin/contacts                     # Liste des contacts
/admin/contacts/:id                 # Détail d'un contact
/admin/contacts/:id/mark_read       # Marquer comme lu
/admin/contacts/export              # Export CSV
/admin/contacts/bulk_action         # Actions en masse

# Analytics
/admin/analytics                    # Analytics principales
/admin/analytics/real_time          # Temps réel
/admin/analytics/pages              # Stats par page
/admin/analytics/referrers          # Sources de trafic
/admin/analytics/regions            # Stats par région

# Sécurité
/admin/security                     # Vue principale
/admin/security/logs                # Logs de sécurité
/admin/security/scan                # Lancer un scan
/admin/security/health              # Health check détaillé
```

## Prochaines Améliorations

### Court terme
- [ ] Tracking automatique des visites sur toutes les pages
- [ ] Actions en masse sur les contacts (suppression, export sélectif)
- [ ] Graphiques interactifs (Chart.js)
- [ ] Notifications par email pour nouveaux contacts
- [ ] Réponse rapide aux contacts depuis l'admin

### Moyen terme
- [ ] Gestion des utilisateurs admin multiples
- [ ] Rôles et permissions (super admin, viewer, etc.)
- [ ] Export PDF des rapports
- [ ] Intégration avec Google Analytics
- [ ] Dashboard personnalisable

### Long terme
- [ ] API REST pour l'admin
- [ ] Application mobile admin
- [ ] Alertes automatiques (SMS, Slack)
- [ ] Machine Learning pour détection d'anomalies
- [ ] Audit trail complet

## Sécurité

### À faire en production:
1. ✅ Changer les identifiants par défaut
2. ⚠️ Activer HTTPS/SSL forcé
3. ⚠️ Configurer les headers de sécurité
4. ⚠️ Installer `bundler-audit` pour vérifier les gems vulnérables
5. ⚠️ Limiter les IPs autorisées (optionnel)
6. ⚠️ Activer le rate limiting
7. ⚠️ Logs réguliers et monitoring

### Headers de sécurité recommandés
Ajouter dans `config/application.rb`:
```ruby
config.action_dispatch.default_headers = {
  'X-Frame-Options' => 'SAMEORIGIN',
  'X-Content-Type-Options' => 'nosniff',
  'X-XSS-Protection' => '1; mode=block',
  'Referrer-Policy' => 'strict-origin-when-cross-origin'
}
```

Pour HSTS (HTTPS strict):
```ruby
config.force_ssl = true
```

## Support

Pour toute question ou problème:
1. Vérifier les logs Rails: `heroku logs --tail`
2. Vérifier la console admin: `/admin/security`
3. Consulter la documentation Rails

---

**Version**: 1.0.0
**Dernière mise à jour**: Mars 2026
