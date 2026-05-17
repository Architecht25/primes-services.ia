import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { delay: { type: Number, default: 0 } }

  connect() {
    this.element.style.opacity = "0"
    this.element.style.transform = "translateY(24px)"
    this.element.style.transition = "opacity 0.65s ease, transform 0.65s ease"

    this.observer = new IntersectionObserver(
      ([entry]) => {
        if (!entry.isIntersecting) return
        setTimeout(() => {
          this.element.style.opacity = "1"
          this.element.style.transform = "translateY(0)"
        }, this.delayValue)
        this.observer.disconnect()
      },
      { threshold: 0.12 }
    )
    this.observer.observe(this.element)
  }

  disconnect() {
    this.observer?.disconnect()
  }
}
