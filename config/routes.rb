Rails.application.routes.draw do
  # Formulaire de contact unique
  resources :contacts, only: [:new, :create, :show]

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

  # Routes Administration
  namespace :admin do
    root to: 'dashboard#index'

    # Authentification
    get  'login',  to: 'sessions#new',     as: :login
    post 'login',  to: 'sessions#create'
    delete 'logout', to: 'sessions#destroy', as: :logout

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

    # Sécurité
    get 'security',        to: 'security#index',  as: :security
    get 'security/logs',   to: 'security#logs',   as: :security_logs
    get 'security/scan',   to: 'security#scan',   as: :security_scan
    get 'security/health', to: 'security#health', as: :security_health
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
