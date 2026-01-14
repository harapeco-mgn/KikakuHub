import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "panel", "input"]
  static values = { defaultLabel: String }

  connect() {
    this.refresh()
  }

  toggle() {
    this.refresh(true)
  }

  refresh(fromToggle = false) {
    const enabled = this.checkboxTarget.checked

    this.panelTarget.classList.toggle("hidden", !enabled)
    this.inputTarget.disabled = !enabled

    if (enabled && this.inputTarget.value.trim() === "") {
      this.inputTarget.value = this.defaultLabelValue || "登壇も興味あり"
    }
  }
}