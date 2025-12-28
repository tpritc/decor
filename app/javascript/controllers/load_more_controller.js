import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    infinite: Boolean,
  }

  connect() {
    if (this.infiniteValue) {
      this.loadMoreWhenVisible()
    }
  }

  loadMoreWhenVisible() {
    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          this.clearSelections()
          this.element.requestSubmit()
          observer.unobserve(this.element)
        }
      })
    })

    observer.observe(this.element)
  }

  clearSelections() {
    if (document.activeElement instanceof HTMLElement) {
      document.activeElement.blur()
    }

    this.element
      .querySelectorAll('input[type="checkbox"], input[type="radio"]')
      .forEach(input => { input.checked = false })

    this.element
      .querySelectorAll('select')
      .forEach(sel => {
        Array.from(sel.options).forEach(opt => {
          opt.selected = false
        })
      })
  }
}
