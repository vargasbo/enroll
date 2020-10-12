import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ['recipientList', 'recipientBadge']

  initialize() {
    console.log('initialize')
    this.orgIds = JSON.parse(this.data.get('orgIds'))
    console.log(this.orgIds)
  }

  new_identifier(event) {
    
    let identifierEl = event.currentTarget
    console.log(identifierEl.value)
    if (identifierEl.value.match(/[ ,]/)) { // more than one

    } else {
      let match = this.orgIds.find(org => {
        org.fein == identifierEl.value ||
        org.hbx_id == identifierEl.value
      })
      if (match) {
        let newBadge = this.recipientBadgeTarget.cloneNode(true)
        this.recipientListTarget.appendChild(newBadge)
        newBadge.classList.remove('d-none')
      }
    }
  }
}