import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static values = { 
    url: String,
    userType: String 
  }

  connect() {
    this.sortable = Sortable.create(this.element, {
      handle: '.drag-handle',
      animation: 150,
      ghostClass: 'sortable-ghost',
      chosenClass: 'sortable-chosen',
      dragClass: 'sortable-drag',
      onEnd: this.onEnd.bind(this)
    })
  }

  disconnect() {
    if (this.sortable) {
      this.sortable.destroy()
    }
  }

  onEnd(event) {
    const budgetId = event.item.dataset.budgetId
    const newIndex =  event.newIndex
    const oldIndex = event.oldIndex
    
    if (newIndex === oldIndex) return

    // サーバーに新しい順序を送信
    const formData = new FormData()
    formData.append('new_index', newIndex)
    formData.append('user_type', this.userTypeValue)
    
    fetch(`${this.urlValue}/${budgetId}/reorder`, {
      method: 'PATCH',
      body: formData,
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
      }
    }).catch(error => {
      console.error('Error:', error)
      // エラー時は元の位置に戻す
      if (oldIndex < newIndex) {
        this.element.insertBefore(event.item, this.element.children[oldIndex])
      } else {
        this.element.insertBefore(event.item, this.element.children[oldIndex + 1])
      }
    })
  }
}