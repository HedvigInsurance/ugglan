import Foundation

public struct ContactInfo: Equatable, Hashable, Sendable {
    public let email: String
    public let phone: String

    public init(email: String, phone: String) {
        self.email = email
        self.phone = phone
    }
}

public enum OnboardingStepList {
    public static func compute(
        contactInfo: ContactInfo = .init(email: "", phone: "")
    ) -> [OnboardingStep] {
        [
            .welcome,
            .analyticsConsent,
            .phoneNumber(phoneNumber: contactInfo.phone, email: contactInfo.email),
            .theme,
        ]
    }
}
