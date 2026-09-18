import { Controller } from "@hotwired/stimulus"

// Compte à rebours vers une échéance (ex: fin d'un régime de primes).
export default class extends Controller {
  static targets = ["days", "hours", "minutes", "seconds"]
  static values = {
    deadline: String,
    expiredMessage: String,
  }

  connect() {
    this.deadline = new Date(this.deadlineValue)
    this.update()
    this.interval = setInterval(() => this.update(), 1000)
  }

  disconnect() {
    clearInterval(this.interval)
  }

  update() {
    const diff = this.deadline - new Date()

    if (diff <= 0) {
      clearInterval(this.interval)
      this.element.innerHTML = `<span class="text-red-800 font-bold">${this.expiredMessageValue}</span>`
      return
    }

    const days = Math.floor(diff / 86400000)
    const hours = Math.floor((diff % 86400000) / 3600000)
    const minutes = Math.floor((diff % 3600000) / 60000)
    const seconds = Math.floor((diff % 60000) / 1000)

    this.daysTarget.textContent = String(days).padStart(3, "0")
    this.hoursTarget.textContent = String(hours).padStart(2, "0")
    this.minutesTarget.textContent = String(minutes).padStart(2, "0")
    this.secondsTarget.textContent = String(seconds).padStart(2, "0")
  }
}
