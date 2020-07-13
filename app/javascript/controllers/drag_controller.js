import { Controller } from "stimulus"
import Sortable from "sortablejs"
import Rails from 'rails-ujs';

export default class extends Controller {
	connect() {
		this.sortable = Sortable.create(this.element, {
			onEnd: this.end.bind(this)
		})
	}

	end(event) {
		let index = event.item.dataset.index
		let market_kind = event.item.dataset.market_kind
		let data = []
		var cards = document.querySelectorAll('.card.mb-4')
		market_kind = market_kind
		data = [...cards].reduce(function(data, card, index) { return [...data, { id: card.dataset.id, position: index + 1 }] }, [])
		fetch('sort',{
			method: 'PATCH',
			body: JSON.stringify({market_kind: market_kind, sort_data: data}),
			headers: {
								'Content-Type': 'application/json',
								'X-CSRF-Token': Rails.csrfToken()
								}
		})
	}
}