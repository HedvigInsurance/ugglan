import Flow
import Form
import Foundation
import Presentation
import SwiftUI
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct MultiQuoteCoverage {
    @PresentableStore var store: OfferStore

    let quotes: [QuoteBundle.Quote]
}

extension MultiQuoteCoverage: View {
    var body: some View {
        hSection(quotes) { quote in
            hRow {
                hText(quote.displayName)
            }
            .onTap {
                store.send(.openQuoteCoverage(quote: quote))
            }
        }
        .withHeader {
            VStack(spacing: 10) {
                L10n.contractCoverageMoreInfo
                    .hText(.title3)
                    .foregroundColor(hTextColor.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                L10n.OfferScreenMULTIPLEINSURANCES.coverageParagraph
                    .hText(.body)
                    .foregroundColor(hTextColor.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
