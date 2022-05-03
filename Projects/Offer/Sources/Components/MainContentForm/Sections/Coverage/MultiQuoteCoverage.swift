import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL
import SwiftUI

struct MultiQuoteCoverage {
    @PresentableStore var store: OfferStore
    
    let quotes: [QuoteBundle.Quote]
}

extension MultiQuoteCoverage: View {
    var body: some View {
        hSection(quotes) { quote in
            hRow {
                hText(quote.displayName)
            }.onTap {
                store.send(.openQuoteCoverage(quote: quote))
            }
        }.withHeader {
            VStack(spacing: 10) {
                L10n.contractCoverageMoreInfo
                    .hText(.title3)
                    .foregroundColor(hLabelColor.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                L10n.OfferScreenMULTIPLEINSURANCES.coverageParagraph
                    .hText(.body)
                    .foregroundColor(hLabelColor.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

