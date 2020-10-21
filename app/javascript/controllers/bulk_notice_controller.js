import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ['recipientList', 'recipientBadge', 'audienceSelect']

  initialize() {
    this.orgIds = JSON.parse(this.data.get('orgIds'))
    console.log(this.orgIds)
  }

  newIdentifier(event) {
    let identifierEl = event.currentTarget
    if (identifierEl.value == "") return

    if (identifierEl.value.match(/[ ,]/)) { // more than one
      let results = { found: [], not_found: [], invalid: [] }
      identifierEl.value.split(/\s*,?\s/).forEach((id) => {
        this.matchHandler(id)
      })
    } else {
      this.matchHandler(identifierEl.value)
    }
    identifierEl.value = ''
  }

  matchHandler(matcher) {
    let match = this.findMatchingOrg(matcher)

    if (match) {
      if (this.typesMatchCheck(match))
        this.newSuccessBadge(match)
      else
        this.newErrorBadge(match.legal_name)
    } else {
      this.newErrorBadge(id)
    }
  }

  newSuccessBadge(match) {
    let newBadge = this.recipientBadgeTarget.cloneNode(true)
    newBadge.prepend(match.legal_name + ' ')
    newBadge.querySelector('input').setAttribute('value', match.id)
    this.recipientListTarget.querySelector('textarea').insertAdjacentElement('beforebegin', newBadge)
    newBadge.classList.remove('d-none')
  }

  newErrorBadge(invalidId) {
    let newBadge = this.recipientBadgeTarget.cloneNode(true)
    newBadge.prepend(invalidId + ' ')
    newBadge.classList.remove('badge-secondary')
    newBadge.classList.add('badge-danger')
    newBadge.querySelector('input:not([value])').remove()
    this.recipientListTarget.querySelector('textarea').insertAdjacentElement('beforebegin', newBadge)
    newBadge.classList.remove('d-none')
  }

  notAlreadyPresent(match) {
    this.receipientListTarget.queryAll
  }

  findMatchingOrg(identifier) {
    return this.orgIds.find(org => {
      return org.fein == identifier || org.hbx_id == identifier
    })
  }

  typesMatchCheck(match) {
    if (this.audienceSelectTarget.value == "employer") {
      return match.entity_type == "employer" || match.entity_type == "employee"
    } else {
      return this.audienceSelectTarget.value == match.entity_type
    }
  }

  deleteIdentifier(event) {
    let identifierEl = event.currentTarget.closest('span.badge')
    identifierEl.remove()
    event.preventDefault()
    return false
  }

  resetIdentifiers(event) {
    this.recipientListTarget.querySelectorAll('span.badge:not(:first-child)').forEach((element) => element.remove())
  }
}