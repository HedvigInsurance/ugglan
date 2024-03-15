import Foundation
import SwiftUI
import hCore
import hCoreUI

enum ProfileRowType {
    case myInfo, appInfo, settings, travelCertificate, forever
    case eurobonus(hasEnteredNumber: Bool)

    var title: String {
        switch self {
        case .myInfo:
            return L10n.profileMyInfoRowTitle
        case .appInfo:
            return L10n.profileAppInfo
        case .settings:
            return L10n.EmbarkOnboardingMoreOptions.settingsLabel
        case .eurobonus:
            return L10n.SasIntegration.title
        case .travelCertificate:
            return L10n.TravelCertificate.cardTitle
        case .forever:
            return L10n.profileForeverTitle
        }
    }

    var icon: UIImage {
        switch self {
        case .myInfo:
            return hCoreUIAssets.memberCard.image
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
        case .travelCertificate:
            return hCoreUIAssets.documentsMultiple.image
        case .forever:
            return hCoreUIAssets.foreverIcon.image
        }
    }

    var action: ProfileAction {
        switch self {
        case .myInfo:
            return .openProfile
        case .appInfo:
            return .openAppInformation
        case .settings:
            return .openAppSettings(animated: true)
        case .eurobonus:
            return .openEuroBonus
        case .travelCertificate:
            return .openTravelCertificate
        case .forever:
            return .openForever
        }
    }

    var imageSize: CGFloat {
        switch self {
        case .myInfo, .appInfo, .settings, .travelCertificate, .forever:
            return 40
        case let .eurobonus(hasEnteredNumber):
            return hasEnteredNumber ? 25 : 40
        }
    }

    var paddings: CGFloat {
        return (40 - imageSize) / 2
    }
}
