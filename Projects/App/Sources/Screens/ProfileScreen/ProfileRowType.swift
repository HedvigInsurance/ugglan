import Foundation
import UIKit
import hCore
import hCoreUI

enum ProfileRowType {
    case myInfo, myCharity, payment, appInfo, settings, eurobonus(hasEnteredNumber: Bool)

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
        case .eurobonus:
            return L10n.SasIntegration.title
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
        case let .eurobonus(hasEnteredNumber):
            if hasEnteredNumber {
                return Asset.euroBonusWithValueRowIcon.image
            } else {
                return Asset.euroBonusRowIcon.image
            }
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
        case .eurobonus:
            return .openEuroBonus
        }
    }
    
    var imageSize: CGFloat {
        switch self {
        case .myInfo:
            return 40
        case .myCharity:
            return 40
        case .payment:
            return 40
        case .appInfo:
            return 40
        case .settings:
            return 40
        case let .eurobonus(hasEnteredNumber):
            return hasEnteredNumber ? 25 : 40
        }
    }
    
    var paddings: CGFloat {
        return (40 - imageSize) / 2
    }
}
