import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL
import SwiftUI

struct QuoteCoverage {
    let quote: QuoteBundle.Quote
}

extension QuoteCoverage: View {
    var body: some View {
        hForm {
            SingleQuoteCoverage(quote: quote)
        }
    }
}

extension QuoteCoverage {
    var journey: some JourneyPresentation {
        HostingJourney(rootView: self)
            .withDismissButton
            .setOptions([.prefersLargeTitles(true), .largeTitleDisplayMode(.always)])
            .configureTitle(L10n.offerScreenCoverageTitle)
    }
}
