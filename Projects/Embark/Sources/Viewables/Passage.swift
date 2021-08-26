import Flow
import Form
import Foundation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct Passage {
	@PresentableStore var store: EmbarkStateStore
}

extension Passage: Viewable {
	func materialize(events _: ViewableEvents) -> (UIView, Signal<hEmbarkLink>) {
		let view = UIStackView()
		view.axis = .vertical
		view.distribution = .equalSpacing
		view.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
		view.isLayoutMarginsRelativeArrangement = true
		view.spacing = 15
		let bag = DisposeBag()

		let embarkMessages = EmbarkMessages()
		bag += view.addArranged(embarkMessages)

		let action = Action()

		bag += state.currentPassageSignal.onValue { passage in print("API", passage?.api ?? "none") }

		bag += state.apiResponseSignal.onValue { link in
			guard let link = link else { return }
			self.state.goTo(passageName: link.name, pushHistoryEntry: false)
		}

		return (
			view,
			Signal { callback in bag += view.addArranged(action).onValue(callback)
				return bag
			}
		)
	}
}
