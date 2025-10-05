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

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Homepage comme route root
  root "pages#home"
end
