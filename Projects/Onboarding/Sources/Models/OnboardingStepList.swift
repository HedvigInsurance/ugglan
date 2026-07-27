import Foundation
import hCore

public struct ContactInfo: Equatable, Hashable, Sendable {
    public let phone: String

    public init(phone: String) {
        self.phone = phone
    }
}

public enum OnboardingStepList {
    public static func compute(
        contactInfo: ContactInfo = .init(phone: "")
    ) -> [OnboardingStep] {
        [
            .welcome,
            .analyticsConsent,
            .phoneNumber(phoneNumber: contactInfo.phone),
        ]
    }
}
