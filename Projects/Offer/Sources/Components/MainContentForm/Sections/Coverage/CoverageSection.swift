import Flow
import Form
import Foundation
import Presentation
import SwiftUI
import UIKit
import hCore
import hCoreUI

struct CoverageSection {}

extension CoverageSection: View {
    var body: some View {
        VStack {
            PresentableStoreLens(
                OfferStore.self,
                getter: { $0.currentVariant?.bundle.quotes ?? [] }
            ) { quotes in
                if quotes.count > 1 {
                    MultiQuoteCoverage(quotes: quotes)
                } else {
                    ForEach(quotes) { quote in
                        SingleQuoteCoverage(quote: quote)
                    }
                }
            }
        }
    }
}
