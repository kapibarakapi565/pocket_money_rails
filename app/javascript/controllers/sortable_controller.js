import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { 
    url: String,
    userType: String 
  }

  connect() {
    console.log('Sortable controller connected')
    console.log('Element:', this.element)
    console.log('URL value:', this.urlValue)
    console.log('User type value:', this.userTypeValue)
    console.log('Window Sortable available:', typeof window.Sortable)
    
    // Sortableの読み込みを待つ
    this.waitForSortable()
  }
  
  waitForSortable() {
    if (typeof window.Sortable !== 'undefined') {
      this.initializeSortable()
    } else {
      // SortableJSが読み込まれるまで待つ
      setTimeout(() => this.waitForSortable(), 100)
    }
  }
  
  initializeSortable() {
    try {
      this.sortable = window.Sortable.create(this.element, {
        animation: 150,
        ghostClass: 'sortable-ghost',
        chosenClass: 'sortable-chosen',
        dragClass: 'sortable-drag',
        onEnd: this.onEnd.bind(this)
      })
      console.log('Sortable created:', this.sortable)
    } catch (error) {
      console.error('Error creating Sortable:', error)
    }
  }

  disconnect() {
    if (this.sortable) {
      this.sortable.destroy()
    }
  }

  onEnd(event) {
    console.log('onEnd triggered')
    console.log('Event:', event)
    
    const budgetId = event.item.dataset.budgetId
    const newIndex =  event.newIndex
    const oldIndex = event.oldIndex
    
    console.log('Budget ID:', budgetId)
    console.log('New index:', newIndex)
    console.log('Old index:', oldIndex)
    
    if (newIndex === oldIndex) {
      console.log('No change in position')
      return
    }

    // サーバーに新しい順序を送信
    const formData = new FormData()
    formData.append('new_index', newIndex)
    formData.append('user_type', this.userTypeValue)
    
    const url = `${this.urlValue}/${budgetId}/reorder`
    console.log('Request URL:', url)
    console.log('Form data:', Object.fromEntries(formData))
    
    fetch(url, {
      method: 'PATCH',
      body: formData,
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
      }
    }).then(response => {
      console.log('Response:', response)
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
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