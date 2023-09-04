import Flow
import Form
import Foundation
import Presentation
import SwiftUI
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct SingleQuoteCoverage {
    @PresentableStore var store: OfferStore

    let quote: QuoteBundle.Quote
}

extension SingleQuoteCoverage: View {
    var body: some View {
        VStack {
            hText(L10n.offerScreenCoverageTitle, style: .title3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 15)
            PerilCollection(
                perils: quote.perils,
                didTapPeril: { peril in
                    store.send(.openPerilDetail(peril: peril))
                }
            )
            .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
            InsurableLimitsSectionView(
                limits: quote.insurableLimits
            ) { limit in
                store.send(.openInsurableLimit(limit: limit))
            }
            DocumentsSection(quote: quote)
        }
    }
}
