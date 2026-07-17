import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  submit() {
    clearTimeout(this.timeout)
    // Debounce the submission for 250ms so it doesn't fire on every single keystroke
    this.timeout = setTimeout(() => {
      this.element.requestSubmit()
    }, 250)
  }
}