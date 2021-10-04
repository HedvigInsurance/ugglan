import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct SingleQuoteCoverage {
    let quote: QuoteBundle.Quote
}

extension SingleQuoteCoverage: Presentable {
    func materialize() -> (SectionView, Disposable) {
        let section = SectionView(
            headerView: UILabel(value: L10n.offerScreenCoverageTitle, style: .default),
            footerView: nil
        )
        section.dynamicStyle = .brandGrouped(separatorType: .none)

        let bag = DisposeBag()

        bag += section.append(
            PerilCollection(
                perilSignal: .init(quote.perils)
            )
            .insetted(UIEdgeInsets(top: 15, left: 15, bottom: 0, right: 15))
        )

        section.appendSpacing(.inbetween)

        let insurableLimits = quote
            .insurableLimits

        bag += section.append(
            InsurableLimitsSection(insurableLimits: insurableLimits)
        )

        section.appendSpacing(.inbetween)

        bag += section.append(DocumentsSection(quote: quote))

        return (section, bag)
    }
}
