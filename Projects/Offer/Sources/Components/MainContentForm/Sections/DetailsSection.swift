import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

struct DetailsSection {
	@Inject var state: OfferState
}

extension DetailsSection: Presentable {
	func materialize() -> (UIView, Disposable) {
		let section = SectionView(headerView: nil, footerView: nil)
		section.dynamicStyle = .brandGrouped(separatorType: .none)
		let bag = DisposeBag()

		bag += state.quotesSignal.onValueDisposePrevious { quotes in
			quotes.enumerated()
				.map { (offset, quote) -> DisposeBag in
					let innerBag = DisposeBag()

					innerBag += section.append(quote.detailsTable.fragments.detailsTableFragment)
					return innerBag
				}
				.disposable
		}

		let expandableView = ExpandableContent(
			contentView: section,
			isExpanded: .init(false),
			collapsedMaxHeight: 400
		)
		.materialize(into: bag)

		return (expandableView, bag)
	}
}
