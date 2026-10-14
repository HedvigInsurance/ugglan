import AutomaticLog
import Contracts
import CrossSell
import Foundation
import Payment
import hCoreUI

public enum OnboardingStep: Hashable, Sendable {
    case welcome
    case analyticsConsent
    case phoneNumber(phoneNumber: String)
    case theme
    case coInsured(contracts: [OnboardingContract])
    case coOwners(contracts: [OnboardingContract])
    case petChipIds(contracts: [OnboardingContract])
    case inviteFriend(discountCode: String, monthlyDiscountPerReferral: String)
    case connectPayment(connectedProvider: PaymentProvider?)
    case crossSell(_ crossSells: [CrossSell])
}

extension OnboardingStep: MaskedValue {
    // An associated value cannot carry `@Masked`, so the masking is written out here:
    // the phone number and the referral code never reach the log, while every other step
    // is described as usual.
    public var maskedDescription: String {
        switch self {
        case .welcome:
            return "welcome"
        case .analyticsConsent:
            return "analyticsConsent"
        case let .phoneNumber(phoneNumber):
            return "phoneNumber(phoneNumber: \(AutomaticLog.maskedLogDescription(phoneNumber)))"
        case .theme:
            return "theme"
        case let .coInsured(contracts):
            return "coInsured(contracts: \(AutomaticLog.logDescription(contracts)))"
        case let .coOwners(contracts):
            return "coOwners(contracts: \(AutomaticLog.logDescription(contracts)))"
        case let .petChipIds(contracts):
            return "petChipIds(contracts: \(AutomaticLog.logDescription(contracts)))"
        case let .inviteFriend(discountCode, monthlyDiscountPerReferral):
            return "inviteFriend(discountCode: \(AutomaticLog.maskedLogDescription(discountCode)), "
                + "monthlyDiscountPerReferral: \(monthlyDiscountPerReferral))"
        case let .connectPayment(connectedProvider):
            return "connectPayment(connectedProvider: \(AutomaticLog.logDescription(connectedProvider as Any)))"
        case let .crossSell(crossSells):
            return "crossSell(\(AutomaticLog.logDescription(crossSells)))"
        }
    }
}

@MainActor
extension OnboardingStep {
    /// Case identity, ignoring associated values — each case appears at most once per flow,
    /// so screens can advance with a step rebuilt from the payload they were handed.
    func matches(_ other: OnboardingStep) -> Bool {
        nameForTracking == other.nameForTracking
    }
}

extension OnboardingStep: TrackingViewNameProtocol {
    public var nameForTracking: String {
        switch self {
        case .welcome: "OnboardingWelcome"
        case .analyticsConsent: "OnboardingAnalyticsConsent"
        case .phoneNumber: "OnboardingPhoneNumber"
        case .theme: "OnboardingTheme"
        case .coInsured: "OnboardingCoInsured"
        case .coOwners: "OnboardingCoOwners"
        case .petChipIds: "OnboardingPetChipIds"
        case .inviteFriend: "OnboardingInviteFriend"
        case .connectPayment: "OnboardingConnectPayment"
        case .crossSell: "OnboardingCrossSell"
        }
    }
}
