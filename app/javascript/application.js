// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Turbo View Transitions — cross-fade fluide entre les pages
document.addEventListener("turbo:before-render", (event) => {
  if (!document.startViewTransition) return
  event.preventDefault()
  document.startViewTransition(() => event.detail.resume())
})
