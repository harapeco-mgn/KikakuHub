import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // Add Slot ボタン（data-availability-slots-wday-param）から wday を受け取る
  add(event) {
    event.preventDefault()

    const wday = event.params.wday
    const list = this.element.querySelector(`[data-slot-list="${wday}"]`)
    const template = this.element.querySelector(`template[data-slot-template="${wday}"]`)
    if (!list || !template) return

    // bulk_update 側で new_ 始まりを「新規」と判定しているので new_... のキーにする
    const key = `new_${wday}_${Date.now()}_${Math.random().toString(16).slice(2)}`
    const html = template.innerHTML.replaceAll("__KEY__", key)
    const fragment = document.createRange().createContextualFragment(html)

    list.appendChild(fragment)

    // 下書き保持（タブ切替・リロード対策）
    this.element.dispatchEvent(new CustomEvent("availability:draft-save", { bubbles: true }))
  }

  // 追加した未保存行を DOM から消す（DB削除ではない）
  remove(event) {
    event.preventDefault()

    const row = event.currentTarget.closest(".js-slot-row")
    if (row) row.remove()

    // 下書き保持
    this.element.dispatchEvent(new CustomEvent("availability:draft-save", { bubbles: true }))
  }
}