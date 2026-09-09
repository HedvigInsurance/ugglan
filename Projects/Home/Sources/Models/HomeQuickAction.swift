import Foundation
import SubmitClaimChat
import hCore
import hCoreUI

public enum HomeQuickAction: Identifiable, Equatable {
    case editInsurance(EditInsuranceActionsWrapper)
    case changeAddress
    case travelCertificate
    case sickAbroad(Deflection)
    case upcomingPayment
    case inviteFriend
    case upgradeCoverage

    public var id: String {
        switch self {
        case .editInsurance: "home.editInsurance"
        case .changeAddress: "home.changeAddress"
        case .travelCertificate: "home.travelCertificate"
        case .sickAbroad: "home.sickAbroad"
        case .upcomingPayment: "home.upcomingPayment"
        case .inviteFriend: "home.inviteFriend"
        case .upgradeCoverage: "home.upgradeCoverage"
        }
    }

    var title: String {
        switch self {
        case .editInsurance: L10n.homeQuickActionsEditInsurance
        case .changeAddress: L10n.homeQuickActionsChangeAddress
        case .travelCertificate: L10n.homeQuickActionsTravelCert
        case .sickAbroad: L10n.hcQuickActionsSickAbroadTitle
        case .upcomingPayment: L10n.homeQuickActionsUpcomingPayment
        case .inviteFriend: L10n.homeQuickActionsInvite
        case .upgradeCoverage: L10n.homeQuickActionsUpgradeCoverage
        }
    }

    @MainActor var icon: ImageAsset {
        switch self {
        case .editInsurance: hCoreUIAssets.settings
        case .changeAddress: hCoreUIAssets.houseArrow
        case .travelCertificate: hCoreUIAssets.travel
        case .sickAbroad: hCoreUIAssets.bandage
        case .upcomingPayment: hCoreUIAssets.paymentOutlined
        case .inviteFriend: hCoreUIAssets.campaignOutlined
        case .upgradeCoverage: hCoreUIAssets.documentPlus
        }
    }
}
