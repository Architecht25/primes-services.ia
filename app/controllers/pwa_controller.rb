class PwaController < ApplicationController
  # Gère les fonctionnalités PWA : manifest, service worker, installation

  def manifest
    # Génère le manifest.json avec configuration dynamique
    respond_to do |format|
      format.json { render template: 'pwa/manifest.json.erb', content_type: 'application/json' }
    end
  end

  def service_worker
    # Sert le service worker
    respond_to do |format|
      format.js { render template: 'pwa/service-worker.js', content_type: 'application/javascript' }
    end
  end

  def offline
    # Page affichée en mode hors ligne
    render 'pages/offline'
  end

  def install_prompt
    # API pour déclencher l'installation PWA
    render json: { status: 'ready_to_install' }
  end

  def subscribe_notifications
    # Gère l'abonnement aux notifications push
    subscription_params = params.require(:subscription).permit(:endpoint, keys: [:p256dh, :auth])

    # Ici on pourrait sauvegarder l'abonnement en base
    # PushSubscription.create(subscription_params.merge(user_id: current_user&.id))

    render json: { status: 'subscribed' }
  end

  def send_notification
    # Envoie une notification push de test
    notification_data = {
      title: params[:title] || "Primes Services IA",
      body: params[:body] || "Une nouvelle prime est disponible !",
      icon: "/icon.png",
      badge: "/icon.png",
      data: {
        url: params[:url] || root_path
      }
    }

    # Ici on utiliserait un service de notifications push
    # PushNotificationService.send_to_user(current_user, notification_data)

    render json: { status: 'sent', data: notification_data }
  end
end
