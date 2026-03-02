import { Controller } from "@hotwired/stimulus"

// Contrôleur Stimulus pour la géolocalisation
export default class extends Controller {
  static targets = ["region", "city", "postalCode", "status"]
  static values = {
    autoDetect: Boolean,
    apiUrl: String
  }

  connect() {
    console.log("Geolocation controller connected")

    if (this.autoDetectValue) {
      this.detectLocation()
    }
  }

  // Détection automatique de la localisation
  detectLocation() {
    this.updateStatus("Détection de votre localisation...")

    if (!navigator.geolocation) {
      this.updateStatus("Géolocalisation non supportée par votre navigateur")
      this.fallbackToIP()
      return
    }

    const options = {
      enableHighAccuracy: true,
      timeout: 10000,
      maximumAge: 300000 // 5 minutes
    }

    navigator.geolocation.getCurrentPosition(
      (position) => this.onLocationSuccess(position),
      (error) => this.onLocationError(error),
      options
    )
  }

  // Succès de la géolocalisation GPS
  async onLocationSuccess(position) {
    const { latitude, longitude } = position.coords
    console.log(`Position détectée: ${latitude}, ${longitude}`)

    this.updateStatus("Localisation détectée, recherche de votre région...")

    try {
      // Géocodage inverse pour obtenir l'adresse
      const locationData = await this.reverseGeocode(latitude, longitude)
      this.updateLocationFields(locationData)
      this.updateStatus("Localisation mise à jour avec succès")
    } catch (error) {
      console.error("Erreur géocodage:", error)
      this.updateStatus("Erreur lors de l'identification de votre région")
      this.fallbackToIP()
    }
  }

  // Erreur de géolocalisation GPS
  onLocationError(error) {
    let message = ""

    switch(error.code) {
      case error.PERMISSION_DENIED:
        message = "Autorisation de géolocalisation refusée"
        break
      case error.POSITION_UNAVAILABLE:
        message = "Position non disponible"
        break
      case error.TIMEOUT:
        message = "Délai de géolocalisation dépassé"
        break
      default:
        message = "Erreur de géolocalisation inconnue"
        break
    }

    console.log("Erreur géolocalisation:", message)
    this.updateStatus(message)
    this.fallbackToIP()
  }

  // Fallback: détection par IP
  async fallbackToIP() {
    this.updateStatus("Détection par adresse IP...")

    try {
      const response = await fetch('/api/geolocation/detect-by-ip', {
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest'
        }
      })

      if (response.ok) {
        const data = await response.json()
        this.updateLocationFields(data)
        this.updateStatus("Région détectée approximativement")
      } else {
        throw new Error('Erreur API')
      }
    } catch (error) {
      console.error("Erreur détection IP:", error)
      this.updateStatus("Impossible de détecter automatiquement votre région")
      this.showManualSelection()
    }
  }

  // Géocodage inverse (GPS vers adresse)
  async reverseGeocode(lat, lng) {
    // Utiliser l'API de géolocalisation interne
    const apiUrl = this.apiUrlValue || '/api/geolocation/reverse'

    const response = await fetch(`${apiUrl}?lat=${lat}&lng=${lng}`, {
      headers: {
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'
      }
    })

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`)
    }

    return await response.json()
  }

  // Mise à jour des champs de localisation
  updateLocationFields(locationData) {
    if (this.hasRegionTarget && locationData.region) {
      this.regionTarget.value = locationData.region
      this.regionTarget.dispatchEvent(new Event('change'))
    }

    if (this.hasCityTarget && locationData.city) {
      this.cityTarget.value = locationData.city
    }

    if (this.hasPostalCodeTarget && locationData.postal_code) {
      this.postalCodeTarget.value = locationData.postal_code
    }

    // Déclencher un événement personnalisé pour notifier le changement
    this.dispatch("locationDetected", {
      detail: locationData
    })
  }

  // Mise à jour du statut
  updateStatus(message) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = message
      this.statusTarget.classList.remove('hidden')

      // Masquer automatiquement après 5 secondes
      setTimeout(() => {
        this.statusTarget.classList.add('hidden')
      }, 5000)
    }

    console.log("Geolocation status:", message)
  }

  // Afficher la sélection manuelle
  showManualSelection() {
    // Afficher un élément de sélection manuelle si disponible
    const manualSelector = this.element.querySelector('[data-manual-selection]')
    if (manualSelector) {
      manualSelector.classList.remove('hidden')
    }
  }

  // Action pour forcer une nouvelle détection
  refresh() {
    this.detectLocation()
  }

  // Action pour changer manuellement la région
  selectRegion(event) {
    const selectedRegion = event.target.value

    if (selectedRegion) {
      this.dispatch("regionSelected", {
        detail: { region: selectedRegion }
      })

      this.updateStatus(`Région sélectionnée: ${selectedRegion}`)
    }
  }
}
