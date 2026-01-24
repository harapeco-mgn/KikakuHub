import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    category: String,
    clear: Boolean,
  }

  connect() {
    // 保存成功後（noticeあり）のときは、下書きを消してから復元しない
    if (this.clearValue) {
      this.clearDraft()
      return
    }

    this.restoreDraft()

    // Add Slot / Remove など、外部イベントでも下書きを保存
    this.element.addEventListener("availability:draft-save", () => this.saveDraft())

    // 入力のたびに下書きを更新（リロードしても戻せる）
    const form = this.form()
    if (!form) return
    form.addEventListener("input", () => this.saveDraft())
    form.addEventListener("change", () => this.saveDraft())
  }

  // タブクリック時：下書きを保存してから遷移
  switch(event) {
    event.preventDefault()
    this.saveDraft()
    window.location = event.currentTarget.href
  }

  form() {
    return document.getElementById("weekly-availability-form")
  }

  draftKey() {
    return `availabilityDraft:${this.categoryValue}`
  }

  saveDraft() {
    const form = this.form()
    if (!form) return

    const data = {}
    form.querySelectorAll("input, select, textarea").forEach((el) => {
      if (!el.name) return

      if (el.type === "checkbox") {
        data[el.name] = el.checked
      } else if (el.type === "radio") {
        if (el.checked) data[el.name] = el.value
      } else {
        data[el.name] = el.value
      }
    })

    sessionStorage.setItem(this.draftKey(), JSON.stringify(data))
  }

  restoreDraft() {
    const raw = sessionStorage.getItem(this.draftKey())
    if (!raw) return

    const form = this.form()
    if (!form) return

    let data
    try {
      data = JSON.parse(raw)
    } catch (_) {
      return
    }

    Object.entries(data).forEach(([name, value]) => {
      const el = form.querySelector(`[name="${CSS.escape(name)}"]`)
      if (!el) return

      if (el.type === "checkbox") {
        el.checked = !!value
      } else if (el.type === "radio") {
        el.checked = (el.value === value)
      } else {
        el.value = value
      }
    })
  }

  clearDraft() {
    sessionStorage.removeItem(this.draftKey())
  }
}