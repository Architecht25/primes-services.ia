// Stimulus controller pour le dropdown de navigation
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  connect() {
    // Fermer le dropdown quand on clique ailleurs
    document.addEventListener('click', this.closeOnOutsideClick.bind(this))
  }

  disconnect() {
    document.removeEventListener('click', this.closeOnOutsideClick.bind(this))
  }

  toggle(event) {
    event.preventDefault()
    this.menuTarget.classList.toggle('hidden')
  }

  close() {
    this.menuTarget.classList.add('hidden')
  }

  closeOnOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }
}
