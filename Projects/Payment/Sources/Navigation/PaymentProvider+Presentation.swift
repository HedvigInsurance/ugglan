import SwiftUI
import hCoreUI

@MainActor
extension PaymentProvider {
    var payinSetupPresentationStyle: DetentPresentationStyle {
        switch self {
        case .trustly, .unknown, .invoice, .swish:
            return .detent(style: [.large])
        case .nordea:
            return .detent(style: [.height])
        }
    }

    var payinSetupPresentationOptions: DetentPresentationOption {
        switch self {
        case .trustly, .swish:
            return [.disableDismissOnScroll, .withoutGrabber]
        case .nordea, .unknown, .invoice:
            return []
        }
    }

    var payoutSetupPresentationStyle: DetentPresentationStyle {
        switch self {
        case .trustly, .unknown, .invoice:
            return .detent(style: [.large])
        case .swish, .nordea:
            return .detent(style: [.height])
        }
    }

    var payoutSetupPresentationOptions: DetentPresentationOption {
        switch self {
        case .trustly:
            return [.disableDismissOnScroll, .withoutGrabber]
        case .swish, .nordea, .unknown, .invoice:
            return []
        }
    }
}
