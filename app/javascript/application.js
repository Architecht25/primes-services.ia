// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import { initFlowbite } from "flowbite"

// Turbo View Transitions — cross-fade fluide entre les pages
document.addEventListener("turbo:before-render", (event) => {
  if (!document.startViewTransition) return
  event.preventDefault()
  document.startViewTransition(() => event.detail.resume())
})

// Flowbite scanne le DOM par data-attributes (accordéons, dropdowns...) au chargement ;
// Turbo Drive ne redéclenche pas cet événement lors des navigations suivantes, d'où le re-scan manuel.
document.addEventListener("turbo:load", () => {
  initFlowbite()
})
