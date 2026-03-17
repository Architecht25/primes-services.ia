Rails.application.routes.draw do
  # Routes formulaires de contact
  resources :contacts, only: [:index, :new, :create, :show] do
    collection do
      get :particulier
      get :acp
      get :entreprise_immo
    end
  end

  # Pages principales
  get "pages/about", as: :about
  get "pages/offline", as: :offline
  get "pages/simulation", as: :simulation
  get "pages/renovate", as: :renovate

  # Routes SEO régionales  - Pages de contenu pour référencement
  get "regions/:region", to: "regions#show", as: :region
  get "regions/:region/villes", to: "regions#cities", as: :region_cities

  # Routes de simulation par région
  get "simulation/:region", to: "pages#simulation_region", as: :simulation_region
  get "simulation/:region/primes", to: "pages#simulation_primes", as: :simulation_primes
  get "simulation/:region/prets", to: "pages#simulation_prets", as: :simulation_prets

  # Routes IA Chatbot
  namespace :ai do
    get :chat                          # Interface de chat principal
    post :send_message                 # Endpoint pour envoyer un message
    get :history                       # Historique de conversation
    post :reset                        # Réinitialiser conversation
    get :stats                         # Statistiques de conversation
    post :complete                     # Marquer conversation terminée
    get :suggestions                   # Suggestions contextuelles
  end

  # Routes Administration
  namespace :admin do
    root to: 'dashboard#index'

    # Dashboard et analytics
    get 'dashboard', to: 'dashboard#index'

    resources :contacts, only: [:index, :show, :destroy] do
      member do
        post :mark_read
      end
      collection do
        get :export
        post :bulk_action
      end
    end

    # Analytics
    get 'analytics', to: 'analytics#index'
    get 'analytics/real_time', to: 'analytics#real_time'
    get 'analytics/pages', to: 'analytics#pages'
    get 'analytics/referrers', to: 'analytics#referrers'
    get 'analytics/regions', to: 'analytics#regions'

    # Sécurité
    get 'security', to: 'security#index'
    get 'security/logs', to: 'security#logs'
    get 'security/scan', to: 'security#scan'
    get 'security/health', to: 'security#health'
  end

  # Routes PWA
  namespace :pwa do
    get :manifest, defaults: { format: :json }  # Manifest PWA
    get 'service-worker', as: :service_worker    # Service Worker
    get :offline                                 # Page hors ligne
    get :install_prompt                          # Prompt d'installation
    post :subscribe_notifications                # Abonnement notifications
    post :send_notification                      # Envoi notification test
  end

  # Routes de redirection vers Ren0vate
  namespace :redirections do
    get :to_renovate                            # Redirection principale
    post :track_click                           # Tracking des clics
    post :success_callback                      # Callback succès Ren0vate
  end

  # API endpoints pour fonctionnalités avancées
  namespace :api do
    namespace :geolocation do
      get :detect_by_ip                         # Détection région par IP
      get :reverse                              # Géocodage inverse
    end

    namespace :cache do
      get :essential_data                       # Données essentielles pour cache
      post :store_form_draft                    # Stocker brouillon formulaire
      get :get_form_draft                       # Récupérer brouillon
      delete :clear_form_draft                  # Supprimer brouillon
    end
  end

  # Endpoint pour vérification connectivité (utilisé par offline controller)
  get :ping, to: 'application#ping'

  # SEO - Sitemap XML
  get '/sitemap.xml', to: redirect('/sitemaps/sitemap.xml.gz')

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  # get "manifest" => "pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "pwa#service_worker", as: :pwa_service_worker

  # Homepage comme route root
  root "pages#home"
end
