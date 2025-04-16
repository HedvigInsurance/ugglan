import Foundation
import SwiftUI
import hCore
import hCoreUI

enum ProfileRowType {
    case myInfo, appInfo, settings, travelCertificate, certificates, insuranceEvidence
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
        case .certificates:
            return "Certificates"
        case .insuranceEvidence:
            return "Insurance Evidence"
        }
    }
    @MainActor
    var icon: UIImage {
        switch self {
        case .myInfo:
            return hCoreUIAssets.id.image
        case .appInfo:
            return hCoreUIAssets.infoOutlined.image
        case .settings:
            return hCoreUIAssets.settings.image
        case let .eurobonus(hasEnteredNumber):
            if hasEnteredNumber {
                return hCoreUIAssets.euroBonusWithValueRowIcon.image
            } else {
                return hCoreUIAssets.eurobonus.image
            }
        case .travelCertificate, .certificates, .insuranceEvidence:
            return hCoreUIAssets.documents.image
        }
    }

    var imageSize: CGFloat {
        switch self {
        case .myInfo, .appInfo, .settings, .travelCertificate, .certificates, .insuranceEvidence:
            return 40
        case let .eurobonus(hasEnteredNumber):
            return hasEnteredNumber ? 25 : 40
        }
    }

    var paddings: CGFloat {
        return (40 - imageSize) / 2
    }
}
