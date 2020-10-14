import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ['recipientList', 'recipientBadge']

  initialize() {
    this.orgIds = JSON.parse(this.data.get('orgIds'))
  }

  newIdentifier(event) {
    let identifierEl = event.currentTarget
    if (identifierEl.value == "") return

    if (identifierEl.value.match(/[ ,]/)) { // more than one
      let results = { found: [], not_found: [], invalid: [] }
      identifierEl.value.split(/\s*,?\s/).forEach((id) => {
        let match = this.findMatchingOrg(id)
        if (match) {
          this.newSuccessBadge(match)
        } else {
          this.newErrorBadge(id)
        }
      })
    } else {
      let match = this.findMatchingOrg(identifierEl.value)
      if (match) {
        this.newSuccessBadge(match)
      } else {
        this.newErrorBadge(identifierEl.value)
      }
    }
    identifierEl.value = ''
  }

  newSuccessBadge(match) {
    let newBadge = this.recipientBadgeTarget.cloneNode(true)
    newBadge.prepend(match.legal_name)
    newBadge.querySelector('input').setAttribute('value', match.id)
    this.recipientListTarget.appendChild(newBadge)
    newBadge.classList.remove('d-none')
  }

  newErrorBadge(invalidId) {
    let newBadge = this.recipientBadgeTarget.cloneNode(true)
    newBadge.prepend(invalidId)
    newBadge.classList.remove('btn-info')
    newBadge.classList.add('btn-danger')
    this.recipientListTarget.appendChild(newBadge)
    newBadge.querySelector('input:not([value])').remove()
    newBadge.classList.remove('d-none')
  }

  findMatchingOrg(identifier) {
    return this.orgIds.find(org => {
      return org.fein == identifier ||
      org.hbx_id == identifier
    })
  }

  deleteIdentifier(event) {
    let identifierEl = event.currentTarget.closest('button')
    identifierEl.remove()
  }
}