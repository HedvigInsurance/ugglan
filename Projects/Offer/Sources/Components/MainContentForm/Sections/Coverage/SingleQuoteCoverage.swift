import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL
import SwiftUI

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

        let perilCollection = PerilCollection(
            perils: quote.perils,
            didTapPeril: { peril in
                section.viewController?.present(
                    PerilDetail(peril: peril).withCloseButton,
                    style: .detented(.preferredContentSize, .large)
                )
            }
        )
        .padding(EdgeInsets(top: 15, leading: 15, bottom: 0, trailing: 15))
        
        section.append(
            HostingView(rootView: perilCollection)
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
