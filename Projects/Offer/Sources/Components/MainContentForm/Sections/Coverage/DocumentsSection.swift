import Flow
import Form
import Foundation
import Presentation
import SafariServices
import UIKit
import hCore
import hCoreUI
import hGraphQL
import SwiftUI

struct DocumentsSection {
    @PresentableStore var store: OfferStore
    let quote: QuoteBundle.Quote
}

extension DocumentsSection: View {
    var body: some View {
        hSection(quote.insuranceTerms) { term in
            hRow {
                hText(term.displayName)
            }.onTap {
                guard let url = URL(string: term.url) else {
                    return
                }
                store.send(.openDocument(url: url))
            }
        }.withHeader {
            hText(L10n.offerDocumentsSectionTitle)
        }
    }
}
