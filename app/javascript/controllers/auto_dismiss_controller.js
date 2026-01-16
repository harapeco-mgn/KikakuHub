import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { delay: Number }

  connect() {
    const delay = this.hasDelayValue ? this.delayValue : 5000
    this.timeout = setTimeout(() => {
      this.element.remove()
    }, delay)
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }
}
