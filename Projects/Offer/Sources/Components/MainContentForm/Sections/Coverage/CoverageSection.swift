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
		let section = SectionView(headerView: UILabel(value: "Coverage", style: .default), footerView: nil)
		section.dynamicStyle = .brandGrouped(separatorType: .none)

		let bag = DisposeBag()
        
        let contentWrapper = UIStackView()
        section.append(contentWrapper)

        bag += state.quotesSignal.onValueDisposePrevious { quotes in
            let innerBag = DisposeBag()
            
            if quotes.count > 1 {
                innerBag += contentWrapper.addArrangedSubview(MultiQuoteCoverage(quotes: quotes))
            } else if quotes.count == 1 {
                innerBag += contentWrapper.addArrangedSubview(SingleQuoteCoverage(quote: quotes[0]))
            }
            
			return innerBag
		}
        
        bag += state
            .dataSignal
            .compactMap { $0.quoteBundle.inception.asIndependentInceptions }
            .compactMap { $0.inceptions.compactMap { $0.currentInsurer }.count > 0 ? true : nil }
            .onValueDisposePrevious { _ in
                let innerBag = DisposeBag()
                innerBag += section.append(CurrentInsurerSection())
                return innerBag
        }

		return (section, bag)
	}
}
