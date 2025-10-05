// Stimulus controller pour l'interface de chat IA
// Gère l'interaction en temps réel avec le chatbot primes-services.ia
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "messages", 
    "input", 
    "sendButton", 
    "typingIndicator", 
    "suggestions",
    "actions"
  ]

  static values = {
    conversationId: String,
    userType: String,
    userRegion: String,
    apiUrl: String
  }

  connect() {
    console.log("🤖 AI Chat controller connected")
    
    this.initializeChat()
    this.bindEvents()
    this.loadSuggestions()
    
    // Auto-scroll vers le bas lors du chargement
    this.scrollToBottom()
    
    // Focus automatique sur l'input
    if (this.hasInputTarget) {
      this.inputTarget.focus()
    }
  }

  initializeChat() {
    this.isTyping = false
    this.messageQueue = []
    this.conversationActive = true
    
    // Configuration de l'API
    this.apiBaseUrl = this.apiUrlValue || '/ai'
    
    // Initialiser les métadonnées utilisateur
    this.userMetadata = {
      userType: this.userTypeValue,
      userRegion: this.userRegionValue,
      timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
      pageUrl: window.location.href
    }

    console.log("Chat initialized with:", this.userMetadata)
  }

  bindEvents() {
    // Envoi avec Enter (Shift+Enter pour nouvelle ligne)
    if (this.hasInputTarget) {
      this.inputTarget.addEventListener('keydown', this.handleKeyDown.bind(this))
      this.inputTarget.addEventListener('input', this.handleInputChange.bind(this))
    }

    // Gestionnaire pour les actions rapides
    if (this.hasActionsTarget) {
      this.actionsTarget.addEventListener('click', this.handleActionClick.bind(this))
    }
  }

  handleKeyDown(event) {
    if (event.key === 'Enter' && !event.shiftKey) {
      event.preventDefault()
      this.sendMessage()
    }
  }

  handleInputChange(event) {
    const message = event.target.value.trim()
    
    // Activer/désactiver le bouton d'envoi
    if (this.hasSendButtonTarget) {
      this.sendButtonTarget.disabled = message.length === 0 || this.isTyping
    }

    // Redimensionner automatiquement le textarea
    this.autoResizeInput(event.target)
  }

  handleActionClick(event) {
    const actionButton = event.target.closest('[data-action-type]')
    if (!actionButton) return

    event.preventDefault()
    
    const actionType = actionButton.dataset.actionType
    const actionData = JSON.parse(actionButton.dataset.actionData || '{}')

    this.executeAction(actionType, actionData)
  }

  // Envoi d'un message utilisateur
  async sendMessage(messageText = null) {
    const message = messageText || this.inputTarget.value.trim()
    
    if (!message || this.isTyping) return

    try {
      // Afficher le message utilisateur immédiatement
      this.addMessage('user', message)
      
      // Vider l'input et désactiver l'envoi
      this.clearInput()
      this.setTypingState(true)
      
      // Afficher l'indicateur de frappe
      this.showTypingIndicator()

      // Envoyer à l'API
      const response = await this.sendToAPI(message)
      
      if (response.success) {
        // Afficher la réponse de l'IA
        this.addMessage('assistant', response.message, {
          actions: response.actions,
          metadata: response.metadata
        })
        
        // Mettre à jour les suggestions
        this.updateSuggestions(response.actions || [])
        
      } else {
        this.addMessage('system', `Erreur: ${response.error}`)
      }

    } catch (error) {
      console.error('Chat error:', error)
      this.addMessage('system', 'Erreur de connexion. Veuillez réessayer.')
    } finally {
      this.hideTypingIndicator()
      this.setTypingState(false)
      this.scrollToBottom()
    }
  }

  // Envoyer le message à l'API Rails
  async sendToAPI(message) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    const response = await fetch(`${this.apiBaseUrl}/send_message`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken,
        'Accept': 'application/json'
      },
      body: JSON.stringify({
        message: message,
        conversation_id: this.conversationIdValue,
        ...this.userMetadata
      })
    })

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`)
    }

    return await response.json()
  }

  // Ajouter un message à la conversation
  addMessage(role, content, options = {}) {
    const messageElement = this.createMessageElement(role, content, options)
    this.messagesTarget.appendChild(messageElement)
    
    // Animation d'apparition
    requestAnimationFrame(() => {
      messageElement.classList.add('opacity-100', 'translate-y-0')
    })

    this.scrollToBottom()
  }

  createMessageElement(role, content, options = {}) {
    const messageDiv = document.createElement('div')
    messageDiv.className = `message message-${role} opacity-0 translate-y-2 transition-all duration-300`
    
    const timestamp = new Date().toLocaleTimeString('fr-BE', { 
      hour: '2-digit', 
      minute: '2-digit' 
    })

    let messageHTML = ''

    if (role === 'user') {
      messageHTML = `
        <div class="flex justify-end mb-4">
          <div class="bg-blue-500 text-white rounded-lg px-4 py-2 max-w-xs lg:max-w-md">
            <p class="text-sm">${this.escapeHtml(content)}</p>
            <span class="text-xs opacity-75 block mt-1">${timestamp}</span>
          </div>
        </div>
      `
    } else if (role === 'assistant') {
      const actionsHTML = this.buildActionsHTML(options.actions || [])
      
      messageHTML = `
        <div class="flex justify-start mb-4">
          <div class="bg-gray-100 text-gray-800 rounded-lg px-4 py-2 max-w-xs lg:max-w-md">
            <div class="flex items-start space-x-2">
              <div class="w-6 h-6 bg-green-500 rounded-full flex items-center justify-center flex-shrink-0 mt-1">
                <span class="text-white text-xs">🤖</span>
              </div>
              <div class="flex-1">
                <p class="text-sm whitespace-pre-wrap">${this.formatAIContent(content)}</p>
                ${actionsHTML}
                <span class="text-xs opacity-75 block mt-1">${timestamp}</span>
              </div>
            </div>
          </div>
        </div>
      `
    } else if (role === 'system') {
      messageHTML = `
        <div class="flex justify-center mb-4">
          <div class="bg-yellow-100 text-yellow-800 rounded-lg px-3 py-2 text-sm max-w-md text-center">
            ${this.escapeHtml(content)}
          </div>
        </div>
      `
    }

    messageDiv.innerHTML = messageHTML
    return messageDiv
  }

  buildActionsHTML(actions) {
    if (!actions || actions.length === 0) return ''

    const buttonsHTML = actions.map(action => {
      const isPrimary = action.primary ? 'bg-blue-500 text-white hover:bg-blue-600' : 'bg-gray-200 text-gray-700 hover:bg-gray-300'
      
      return `
        <button 
          data-action-type="${action.type}"
          data-action-data='${JSON.stringify(action)}'
          class="inline-block px-3 py-1 rounded text-xs font-medium transition-colors mr-2 mb-1 ${isPrimary}"
        >
          ${this.escapeHtml(action.label)}
        </button>
      `
    }).join('')

    return `<div class="mt-2">${buttonsHTML}</div>`
  }

  formatAIContent(content) {
    // Formater le contenu de l'IA (markdown simple, liens, etc.)
    let formatted = this.escapeHtml(content)
    
    // Gras **texte**
    formatted = formatted.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
    
    // Italique *texte*
    formatted = formatted.replace(/\*(.*?)\*/g, '<em>$1</em>')
    
    // Liens simples
    formatted = formatted.replace(/(https?:\/\/[^\s]+)/g, '<a href="$1" target="_blank" class="text-blue-600 underline">$1</a>')
    
    return formatted
  }

  executeAction(actionType, actionData) {
    console.log('Executing action:', actionType, actionData)

    switch (actionType) {
      case 'form':
        window.location.href = actionData.url
        break
      case 'redirect':
        window.open(actionData.url, '_blank')
        break
      case 'contact':
        window.location.href = actionData.url
        break
      case 'internal':
        window.location.href = actionData.url
        break
      case 'quick_message':
        this.sendMessage(actionData.message)
        break
      default:
        console.warn('Unknown action type:', actionType)
    }
  }

  showTypingIndicator() {
    if (!this.hasTypingIndicatorTarget) return

    this.typingIndicatorTarget.classList.remove('hidden')
    this.typingIndicatorTarget.innerHTML = `
      <div class="flex justify-start mb-4">
        <div class="bg-gray-100 rounded-lg px-4 py-2">
          <div class="flex items-center space-x-2">
            <div class="w-6 h-6 bg-green-500 rounded-full flex items-center justify-center">
              <span class="text-white text-xs">🤖</span>
            </div>
            <div class="typing-dots">
              <span></span>
              <span></span>
              <span></span>
            </div>
          </div>
        </div>
      </div>
    `
  }

  hideTypingIndicator() {
    if (!this.hasTypingIndicatorTarget) return
    this.typingIndicatorTarget.classList.add('hidden')
    this.typingIndicatorTarget.innerHTML = ''
  }

  async loadSuggestions() {
    try {
      const response = await fetch(`${this.apiBaseUrl}/suggestions`, {
        headers: {
          'Accept': 'application/json'
        }
      })

      if (response.ok) {
        const data = await response.json()
        this.updateSuggestions(data.suggestions || [])
      }
    } catch (error) {
      console.warn('Could not load suggestions:', error)
    }
  }

  updateSuggestions(suggestions) {
    if (!this.hasSuggestionsTarget || !suggestions.length) return

    const suggestionsHTML = suggestions.map(suggestion => `
      <button 
        data-action="click->ai-chat#sendSuggestion"
        data-message="${this.escapeHtml(suggestion)}"
        class="suggestion-button bg-gray-100 hover:bg-gray-200 text-gray-700 text-sm px-3 py-2 rounded-full mr-2 mb-2 transition-colors"
      >
        ${this.escapeHtml(suggestion)}
      </button>
    `).join('')

    this.suggestionsTarget.innerHTML = `
      <div class="suggestions-container">
        <p class="text-sm text-gray-600 mb-2">Suggestions:</p>
        ${suggestionsHTML}
      </div>
    `
  }

  sendSuggestion(event) {
    const message = event.target.dataset.message
    if (message) {
      this.sendMessage(message)
    }
  }

  setTypingState(isTyping) {
    this.isTyping = isTyping
    
    if (this.hasSendButtonTarget) {
      this.sendButtonTarget.disabled = isTyping || !this.inputTarget.value.trim()
    }
    
    if (this.hasInputTarget) {
      this.inputTarget.disabled = isTyping
    }
  }

  clearInput() {
    if (this.hasInputTarget) {
      this.inputTarget.value = ''
      this.autoResizeInput(this.inputTarget)
    }
  }

  autoResizeInput(textarea) {
    textarea.style.height = 'auto'
    textarea.style.height = Math.min(textarea.scrollHeight, 120) + 'px'
  }

  scrollToBottom() {
    if (this.hasMessagesTarget) {
      this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
    }
  }

  escapeHtml(text) {
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  }

  // Actions pour les boutons de contrôle
  resetChat() {
    if (confirm('Voulez-vous vraiment réinitialiser la conversation ?')) {
      fetch(`${this.apiBaseUrl}/reset`, {
        method: 'POST',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content,
          'Accept': 'application/json'
        }
      })
      .then(response => response.json())
      .then(data => {
        if (data.success) {
          this.messagesTarget.innerHTML = ''
          this.loadSuggestions()
        }
      })
      .catch(error => console.error('Reset error:', error))
    }
  }

  completeChat() {
    fetch(`${this.apiBaseUrl}/complete`, {
      method: 'POST',
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content,
        'Accept': 'application/json'
      }
    })
    .then(() => {
      this.conversationActive = false
      this.addMessage('system', 'Conversation terminée. Merci pour votre visite !')
    })
    .catch(error => console.error('Complete error:', error))
  }

  disconnect() {
    console.log("🤖 AI Chat controller disconnected")
  }
}