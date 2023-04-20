import Foundation
import UIKit
import hCore

enum ProfileRowType {
    case myInfo, myCharity, payment, appInfo, settings

    var title: String {
        switch self {
        case .myInfo:
            return L10n.profileMyInfoRowTitle
        case .myCharity:
            return L10n.businessModelProfileRow
        case .payment:
            return L10n.profilePaymentRowHeader
        case .appInfo:
            return L10n.OnboardingContextualMenu.appInfoLabel
        case .settings:
            return L10n.EmbarkOnboardingMoreOptions.settingsLabel
        }
    }

    var icon: UIImage {
        switch self {
        case .myInfo:
            return Asset.myInfoRowIcon.image
        case .myCharity:
            return Asset.charityPlain.image
        case .payment:
            return Asset.paymentRowIcon.image
        case .appInfo:
            return Asset.infoIcon.image
        case .settings:
            return Asset.settingsIcon.image
        }
    }

    var action: ProfileAction {
        switch self {
        case .myInfo:
            return .openProfile
        case .myCharity:
            return .openCharity
        case .payment:
            return .openPayment
        case .appInfo:
            return .openAppInformation
        case .settings:
            return .openAppSettings
        }
    }
}
