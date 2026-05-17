import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["submit", "messageCounter"]

  connect() {
    this.fields = this.element.querySelectorAll("[data-validate]")
    this.fields.forEach(field => {
      field.addEventListener("blur", () => this.validateField(field))
      field.addEventListener("input", () => this.clearError(field))
      if (field.tagName === "SELECT") {
        field.addEventListener("change", () => this.validateField(field))
      }
    })

    const messageField = this.element.querySelector("[data-validate~='maxlength']")
    if (messageField) this.updateCounter(messageField)
  }

  validateField(field) {
    const rules = (field.dataset.validate || "").split(" ")
    let error = null

    if (rules.includes("required")) {
      if (!field.value.trim()) {
        error = field.dataset.errorRequired || "Ce champ est obligatoire."
      }
    }

    if (!error && field.value.trim() && rules.includes("email")) {
      const emailRe = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/
      if (!emailRe.test(field.value.trim())) {
        error = "Adresse email invalide."
      }
    }

    if (!error && field.value.trim() && rules.includes("phone")) {
      const phoneRe = /^[+\d][\d\s\-().]{6,20}$/
      if (!phoneRe.test(field.value.trim())) {
        error = "Format invalide (ex: 0475 04 37 45 ou +32 475 04 37 45)."
      }
    }

    if (!error && field.value.trim() && rules.includes("minlength")) {
      const min = parseInt(field.dataset.minlength || 2)
      if (field.value.trim().length < min) {
        error = `Minimum ${min} caractères.`
      }
    }

    if (!error && rules.includes("maxlength")) {
      const max = parseInt(field.dataset.maxlength || 2000)
      if (field.value.length > max) {
        error = `Maximum ${max} caractères (${field.value.length} saisis).`
      }
      this.updateCounter(field)
    }

    if (!error && field.value && rules.includes("minbudget")) {
      const min = parseInt(field.dataset.minbudget || 1000)
      if (parseInt(field.value) > 0 && parseInt(field.value) < min) {
        error = `Minimum ${min.toLocaleString('fr-BE')}€.`
      }
    }

    error ? this.showError(field, error) : this.showSuccess(field)
    this.updateSubmitState()
  }

  validateAll() {
    this.fields.forEach(field => this.validateField(field))
  }

  showError(field, message) {
    field.classList.remove("border-gray-300", "border-green-400")
    field.classList.add("border-red-400", "focus:ring-red-400", "focus:border-red-400")
    field.classList.remove("focus:ring-primary-500", "focus:border-primary-500")

    let errorEl = field.parentElement.querySelector(".field-error")
    if (!errorEl) {
      errorEl = document.createElement("p")
      errorEl.className = "field-error text-red-600 text-xs mt-1 flex items-center gap-1"
      field.parentElement.appendChild(errorEl)
    }
    errorEl.innerHTML = `<svg class="w-3 h-3 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd"/></svg>${message}`
  }

  showSuccess(field) {
    if (!field.value.trim() && !field.dataset.validate?.includes("required")) return
    field.classList.remove("border-gray-300", "border-red-400", "focus:ring-red-400", "focus:border-red-400")
    field.classList.add("border-green-400")
    field.classList.add("focus:ring-primary-500", "focus:border-primary-500")

    const errorEl = field.parentElement.querySelector(".field-error")
    if (errorEl) errorEl.remove()
  }

  clearError(field) {
    field.classList.remove("border-red-400", "focus:ring-red-400", "focus:border-red-400")
    field.classList.add("border-gray-300", "focus:ring-primary-500", "focus:border-primary-500")
    const errorEl = field.parentElement.querySelector(".field-error")
    if (errorEl) errorEl.remove()

    if ((field.dataset.validate || "").includes("maxlength")) {
      this.updateCounter(field)
    }
  }

  updateCounter(field) {
    const max = parseInt(field.dataset.maxlength || 2000)
    const current = field.value.length
    const remaining = max - current

    let counterEl = field.parentElement.querySelector(".char-counter")
    if (!counterEl) {
      counterEl = document.createElement("p")
      counterEl.className = "char-counter text-xs mt-1 text-right"
      field.parentElement.appendChild(counterEl)
    }
    counterEl.textContent = `${current} / ${max}`
    counterEl.className = `char-counter text-xs mt-1 text-right ${remaining < 100 ? "text-amber-600 font-medium" : "text-gray-400"}`
  }

  updateSubmitState() {
    if (!this.hasSubmitTarget) return
    const hasErrors = this.element.querySelectorAll(".field-error").length > 0
    const requiredFilled = [...this.fields]
      .filter(f => f.dataset.validate?.includes("required"))
      .every(f => f.value.trim())
    this.submitTarget.disabled = hasErrors || !requiredFilled
    this.submitTarget.classList.toggle("opacity-50", hasErrors || !requiredFilled)
    this.submitTarget.classList.toggle("cursor-not-allowed", hasErrors || !requiredFilled)
  }

  handleSubmit(event) {
    this.validateAll()
    const hasErrors = this.element.querySelectorAll(".field-error").length > 0
    if (hasErrors) {
      event.preventDefault()
      this.element.querySelector(".field-error")?.closest("[data-validate]")?.focus()
      return
    }
    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = true
      this.submitTarget.innerHTML = `<svg class="animate-spin w-4 h-4 mr-2" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"></path></svg>Envoi en cours…`
    }
  }
}
