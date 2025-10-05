// Stimulus controller pour le chatbot flottant
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "window", "messages", "input", "sendButton", "intro", "badge"]

  connect() {
    console.log("Floating chatbot connected")
    this.isOpen = false
    this.messageCount = 0
    
    // Gérer l'input Enter
    if (this.hasInputTarget) {
      this.inputTarget.addEventListener('keydown', this.handleKeyDown.bind(this))
    }
  }

  toggle() {
    if (this.isOpen) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    this.isOpen = true
    this.windowTarget.classList.remove('hidden', 'scale-95', 'opacity-0')
    this.windowTarget.classList.add('scale-100', 'opacity-100')
    
    // Focus sur l'input
    if (this.hasInputTarget) {
      setTimeout(() => this.inputTarget.focus(), 100)
    }
    
    // Cacher l'intro si elle est visible
    this.dismissIntro()
  }

  close() {
    this.isOpen = false
    this.windowTarget.classList.add('scale-95', 'opacity-0')
    setTimeout(() => {
      this.windowTarget.classList.add('hidden')
    }, 150)
  }

  dismissIntro() {
    if (this.hasIntroTarget) {
      this.introTarget.style.display = 'none'
      localStorage.setItem('ps_chatbot_intro_seen', 'true')
    }
  }

  handleKeyDown(event) {
    if (event.key === 'Enter' && !event.shiftKey) {
      event.preventDefault()
      this.sendMessage()
    }
  }

  async sendMessage() {
    const message = this.inputTarget.value.trim()
    if (!message) return

    // Ajouter le message utilisateur
    this.addMessage('user', message)
    this.inputTarget.value = ''

    // Simuler une réponse (en attendant l'intégration complète)
    setTimeout(() => {
      this.addMessage('assistant', 'Merci pour votre question ! Pour une réponse complète, cliquez sur "Ouvrir en plein écran" ci-dessus.')
    }, 1000)
  }

  sendSuggestion(event) {
    const message = event.target.dataset.message
    if (message) {
      this.inputTarget.value = message
      this.sendMessage()
    }
  }

  addMessage(role, content) {
    const messageDiv = document.createElement('div')
    messageDiv.className = `flex ${role === 'user' ? 'justify-end' : 'justify-start'}`
    
    const timestamp = new Date().toLocaleTimeString('fr-BE', { 
      hour: '2-digit', 
      minute: '2-digit' 
    })

    if (role === 'user') {
      messageDiv.innerHTML = `
        <div class="bg-blue-500 text-white rounded-lg px-3 py-2 max-w-xs text-sm">
          ${this.escapeHtml(content)}
          <div class="text-xs opacity-75 mt-1">${timestamp}</div>
        </div>
      `
    } else {
      messageDiv.innerHTML = `
        <div class="bg-gray-100 rounded-lg px-3 py-2 max-w-xs text-sm">
          <div class="flex items-start space-x-2">
            <div class="w-5 h-5 bg-green-500 rounded-full flex items-center justify-center flex-shrink-0 mt-1">
              <span class="text-white text-xs">🤖</span>
            </div>
            <div>
              ${this.escapeHtml(content)}
              <div class="text-xs opacity-75 mt-1">${timestamp}</div>
            </div>
          </div>
        </div>
      `
    }

    this.messagesTarget.appendChild(messageDiv)
    this.scrollToBottom()
    
    this.messageCount++
    this.updateBadge()
  }

  updateBadge() {
    if (this.hasBadgeTarget && !this.isOpen && this.messageCount > 0) {
      this.badgeTarget.textContent = this.messageCount
      this.badgeTarget.style.display = 'flex'
    } else if (this.hasBadgeTarget) {
      this.badgeTarget.style.display = 'none'
    }
  }

  scrollToBottom() {
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }

  escapeHtml(text) {
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  }
}