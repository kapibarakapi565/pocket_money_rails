import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item", "actions"]
  
  connect() {
    this.selectedItem = null
  }
  
  selectItem(event) {
    // Don't select if clicking on action buttons
    if (event.target.closest('.budget-actions')) {
      return
    }
    
    const clickedItem = event.currentTarget
    
    // If clicking the same item, deselect it
    if (this.selectedItem === clickedItem) {
      this.cancelSelection()
      return
    }
    
    // Cancel previous selection
    this.cancelSelection()
    
    // Select new item
    this.selectedItem = clickedItem
    clickedItem.classList.add('selected')
    
    // Show action buttons for this item
    const actionsElement = clickedItem.querySelector('[data-budget-selector-target="actions"]')
    if (actionsElement) {
      actionsElement.style.display = 'flex'
    }
  }
  
  cancelSelection() {
    if (this.selectedItem) {
      this.selectedItem.classList.remove('selected')
      
      // Hide action buttons
      const actionsElement = this.selectedItem.querySelector('[data-budget-selector-target="actions"]')
      if (actionsElement) {
        actionsElement.style.display = 'none'
      }
      
      this.selectedItem = null
    }
  }
  
  // Handle clicks outside the list to cancel selection
  disconnect() {
    document.removeEventListener('click', this.handleOutsideClick.bind(this))
  }
  
  handleOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.cancelSelection()
    }
  }
}