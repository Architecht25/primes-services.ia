import { Controller } from "@hotwired/stimulus"

// Anime un chiffre de 0 vers sa valeur finale quand il entre dans le viewport.
export default class extends Controller {
  static values = {
    end: Number,
    duration: { type: Number, default: 1500 },
    prefix: { type: String, default: "" },
    suffix: { type: String, default: "" },
  }

  connect() {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      this.render(this.endValue)
      return
    }

    this.observer = new IntersectionObserver(
      ([entry]) => {
        if (!entry.isIntersecting) return
        this.animate()
        this.observer.disconnect()
      },
      { threshold: 0.4 }
    )
    this.observer.observe(this.element)
  }

  disconnect() {
    this.observer?.disconnect()
    if (this.frame) cancelAnimationFrame(this.frame)
  }

  animate() {
    const start = performance.now()

    const step = (now) => {
      const progress = Math.min((now - start) / this.durationValue, 1)
      const eased = 1 - Math.pow(1 - progress, 3)
      this.render(Math.round(this.endValue * eased))
      if (progress < 1) this.frame = requestAnimationFrame(step)
    }

    this.frame = requestAnimationFrame(step)
  }

  render(value) {
    const formatted = value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ".")
    this.element.textContent = `${this.prefixValue}${formatted}${this.suffixValue}`
  }
}
