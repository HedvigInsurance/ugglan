import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

struct CoverageSection {
	@Inject var state: OfferState
}

extension CoverageSection: Presentable {
	func materialize() -> (SectionView, Disposable) {
		let section = SectionView(headerView: nil, footerView: nil)
		section.dynamicStyle = .brandGrouped(separatorType: .none)

		let bag = DisposeBag()

		let contentWrapper = UIStackView()
		section.append(contentWrapper)

		bag += state.quotesSignal.onValueDisposePrevious { quotes in
			let innerBag = DisposeBag()

			if quotes.count > 1 {
				innerBag += contentWrapper.addArrangedSubview(MultiQuoteCoverage(quotes: quotes))
			} else if let quote = quotes.first {
				innerBag += contentWrapper.addArrangedSubview(SingleQuoteCoverage(quote: quote))
			}

			return innerBag
		}

		bag += state
			.dataSignal
			.compactMap { $0.quoteBundle }
			.onValueDisposePrevious { quoteBundle in
				let innerBag = DisposeBag()

				let hasConcurrentInception =
					quoteBundle.inception.asConcurrentInception?.currentInsurer != nil
				let hasIndependentInceptions =
					quoteBundle.inception.asIndependentInceptions?.inceptions
					.compactMap { $0.currentInsurer }.count ?? 0 > 0

				if hasConcurrentInception || hasIndependentInceptions {
					innerBag += section.append(CurrentInsurerSection(quoteBundle: quoteBundle))
				}

				return innerBag
			}

		return (section, bag)
	}
}
