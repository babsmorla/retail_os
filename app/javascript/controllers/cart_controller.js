import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["items", "fields", "total", "subtotal", "tax", "count"]

  connect() {
    console.log("CART CONTROLLER CONNECTED")
    // Load existing cart from localStorage, or default to empty array
    const savedCart = localStorage.getItem("myShopCart")
    this.cart = savedCart ? JSON.parse(savedCart) : []
    this.render()
  }

  // Helper to save to localStorage and trigger visual updates
  saveAndRender() {
    localStorage.setItem("myShopCart", JSON.stringify(this.cart))
    this.render()
  }

  add(event) {
    const id = event.currentTarget.dataset.productId
    const existing = this.cart.find(item => item.id == id)

    if (existing) {
      existing.quantity++
    } else {
      this.cart.push({
        id: id,
        name: event.currentTarget.dataset.productName,
        price: parseFloat(event.currentTarget.dataset.productPrice),
        quantity: 1
      })
    }
    this.saveAndRender() // Updated
  }

  increase(event) {
    const index = event.currentTarget.dataset.index
    this.cart[index].quantity++
    this.saveAndRender() // Updated
  }

  decrease(event) {
    const index = event.currentTarget.dataset.index
    if (this.cart[index].quantity > 1) {
      this.cart[index].quantity--
    }
    this.saveAndRender() // Updated
  }

  remove(event) {
    const index = event.currentTarget.dataset.index
    this.cart.splice(index, 1)
    this.saveAndRender() // Updated
  }

  clear() {
    this.cart = []
    this.saveAndRender() // Updated
  }

  render() {
    // ... (Your existing render logic remains the same)
    this.itemsTarget.innerHTML = ""
    this.fieldsTarget.innerHTML = ""

    this.cart.forEach((item, index) => {
      this.itemsTarget.innerHTML += `
        <div class="flex justify-between items-center py-3 border-b">
          <div>
            <p class="font-semibold">${item.name}</p>
            <p class="text-sm text-gray-500">GH₵${item.price.toFixed(2)}</p>
          </div>
          <div class="flex items-center gap-2">
            <button type="button" class="px-2" data-action="cart#decrease" data-index="${index}">-</button>
            <span>${item.quantity}</span>
            <button type="button" class="px-2" data-action="cart#increase" data-index="${index}">+</button>
            <button type="button" class="text-red-500 text-xs ml-2" data-action="cart#remove" data-index="${index}">Remove</button>
          </div>
        </div>
      `

      this.fieldsTarget.innerHTML += `
        <input type="hidden" name="sale[sale_items_attributes][${index}][product_id]" value="${item.id}">
        <input type="hidden" name="sale[sale_items_attributes][${index}][quantity]" value="${item.quantity}">
        <input type="hidden" name="sale[sale_items_attributes][${index}][unit_price_at_sale]" value="${item.price}">
      `
    })

    this.updateSummary()
  }

  updateSummary() {
    let subtotal = this.cart.reduce((sum, item) => sum + (item.price * item.quantity), 0)
    let tax = subtotal * 0
    let total = subtotal + tax

    if (this.hasSubtotalTarget) this.subtotalTarget.innerHTML = "GHS " + subtotal.toFixed(2)
    if (this.hasTaxTarget) this.taxTarget.innerHTML = "GHS " + tax.toFixed(2)
    this.totalTarget.innerHTML = total.toFixed(2)

    if (this.hasCountTarget) {
      this.countTarget.innerHTML = this.cart.reduce((sum, item) => sum + item.quantity, 0)
    }
  }
}