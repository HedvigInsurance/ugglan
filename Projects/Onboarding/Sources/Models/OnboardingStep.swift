import Foundation
import hCoreUI

public enum OnboardingStep: Hashable, Sendable {
    case welcome
    case analyticsConsent
    case phoneNumber(phoneNumber: String, email: String)
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
        }
    }
}
