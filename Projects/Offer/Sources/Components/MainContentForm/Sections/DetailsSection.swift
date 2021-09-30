import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

struct DetailsSection {}

extension DetailsSection: Presentable {
    func materialize() -> (UIView, Disposable) {
        let section = SectionView(headerView: nil, footerView: nil)
        let store: OfferStore = self.get()
        
        section.dynamicStyle = .brandGrouped(separatorType: .none)
            .restyled({ (style: inout SectionStyle) in
                style.insets = style.insets + UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0)
            })
        let bag = DisposeBag()

        bag += store.stateSignal.compactMap { $0.offerData?.quoteBundle.quotes }.debounce(0.3)
            .onValueDisposePrevious { quotes in
                let innerBag = DisposeBag()
                innerBag += quotes.map { quote in
                    section.append(quote.detailsTable)
                }
                return innerBag
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
