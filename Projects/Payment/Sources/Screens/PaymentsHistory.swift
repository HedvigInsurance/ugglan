import Apollo
import Flow
import Form
import Foundation
import Presentation
import SwiftUI
import UIKit
import hCore
import hCoreUI
import hGraphQL

public struct PaymentHistory: View {
    @PresentableStore var store: PaymentStore
    public var body: some View {
        hText("history")
    }
}

extension PaymentHistory {
    public static var journey: some JourneyPresentation {
        HostingJourney(
            PaymentStore.self,
            rootView: PaymentHistory()
        ) { action in
            if case .goBack = action {
                PopJourney()
            }
        }
        .configureTitle(L10n.paymentHistoryTitle)
    }
}

struct PaymentHistory_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale = .sv_SE
        return PaymentHistory()
    }
}
