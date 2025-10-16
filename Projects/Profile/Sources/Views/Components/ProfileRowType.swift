import Foundation
import SwiftUI
import hCore
import hCoreUI

enum ProfileRowType {
    case myInfo, appInfo, settings, travelCertificate, certificates, insuranceEvidence, claimHistory
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
            return L10n.Profile.Certificates.title
        case .insuranceEvidence:
            return L10n.InsuranceEvidence.documentTitle
        case .claimHistory:
            return L10n.Profile.ClaimHistory.title
        }
    }

    @MainActor
    var icon: Image {
        switch self {
        case .myInfo:
            return hCoreUIAssets.id.view
        case .appInfo:
            return hCoreUIAssets.infoOutlined.view
        case .settings:
            return hCoreUIAssets.settings.view
        case let .eurobonus(hasEnteredNumber):
            if hasEnteredNumber {
                return hCoreUIAssets.euroBonusWithValueRowIcon.view
            } else {
                return hCoreUIAssets.eurobonus.view
            }
        case .travelCertificate, .certificates, .insuranceEvidence:
            return hCoreUIAssets.document.view
        case .claimHistory:
            return hCoreUIAssets.clock.view
        }
    }
}
