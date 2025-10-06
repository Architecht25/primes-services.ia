Rails.application.routes.draw do
  # Routes formulaires de contact
  resources :contacts, only: [:index, :new, :create, :show] do
    collection do
      get :particulier
      get :acp
      get :entreprise_immo
      get :entreprise_comm
    end
  end

  # Pages principales
  get "pages/about", as: :about
  get "pages/offline", as: :offline
  get "pages/faq", as: :faq
  get "pages/data", as: :data

  # Routes SEO géographiques par région
  scope path: '/regions' do
    get '/wallonie', to: 'pages#wallonie', as: :region_wallonie
    get '/flandre', to: 'pages#flandre', as: :region_flandre
    get '/bruxelles', to: 'pages#bruxelles', as: :region_bruxelles

    # Pages par ville principale (SEO longue traîne)
    get '/wallonie/liege', to: 'pages#city', defaults: { region: 'wallonie', city: 'liege' }
    get '/wallonie/charleroi', to: 'pages#city', defaults: { region: 'wallonie', city: 'charleroi' }
    get '/wallonie/namur', to: 'pages#city', defaults: { region: 'wallonie', city: 'namur' }

    get '/flandre/anvers', to: 'pages#city', defaults: { region: 'flandre', city: 'anvers' }
    get '/flandre/gand', to: 'pages#city', defaults: { region: 'flandre', city: 'gand' }
    get '/flandre/bruges', to: 'pages#city', defaults: { region: 'flandre', city: 'bruges' }

    get '/bruxelles/ixelles', to: 'pages#city', defaults: { region: 'bruxelles', city: 'ixelles' }
    get '/bruxelles/uccle', to: 'pages#city', defaults: { region: 'bruxelles', city: 'uccle' }
  end

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
