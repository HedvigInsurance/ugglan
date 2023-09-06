import Foundation
import UIKit
import hCore
import hCoreUI

enum ProfileRowType {
    case myInfo, payment, appInfo, settings
    case eurobonus(hasEnteredNumber: Bool)

    var title: String {
        switch self {
        case .myInfo:
            return L10n.profileMyInfoRowTitle
        case .payment:
            return L10n.profilePaymentRowHeader
        case .appInfo:
            return L10n.profileAppInfo
        case .settings:
            return L10n.EmbarkOnboardingMoreOptions.settingsLabel
        case .eurobonus:
            return L10n.SasIntegration.title
        }
    }

    var icon: UIImage {
        switch self {
        case .myInfo:
            return hCoreUIAssets.memberCard.image
        case .payment:
            return hCoreUIAssets.payments.image
        case .appInfo:
            return hCoreUIAssets.infoIcon.image
        case .settings:
            return hCoreUIAssets.settingsIcon.image
        case let .eurobonus(hasEnteredNumber):
            if hasEnteredNumber {
                return hCoreUIAssets.euroBonusWithValueRowIcon.image
            } else {
                return hCoreUIAssets.eurobonus.image
            }
        }
    }

    var action: ProfileAction {
        switch self {
        case .myInfo:
            return .openProfile
        case .payment:
            return .openPayment
        case .appInfo:
            return .openAppInformation
        case .settings:
            return .openAppSettings(animated: true)
        case .eurobonus:
            return .openEuroBonus
        }
    }

    var imageSize: CGFloat {
        switch self {
        case .myInfo:
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
