import Combine
import Foundation

@MainActor
public protocol FeatureFlagsClient {
    var featureData: AnyPublisher<FeatureData, Never> { get }
    func setup(with context: [String: String]) async throws
    func updateContext(context: [String: String])
}

public struct FeatureData: Codable, Equatable, Sendable {
    public let isUpdateNecessary: Bool
    public let osVersionTooLow: Bool
    public let emailPreferencesEnabled: Bool
    public let isDemoMode: Bool
    public let isNewConversationFromInboxEnabled: Bool
    public let isPuppyGuideEnabled: Bool
    public let isResumeClaimEnabled: Bool
    public let isOnboardingEnabled: Bool
    public let isTerminationRedirectionEnabled: Bool
    public let isAnalyticsEnabled: Bool
    public let isResumingOngoingShopSessionsEnabled: Bool
    public let isCancelInsuranceHiddenFromHomeScreen: Bool

    public init(
        isUpdateNecessary: Bool,
        osVersionTooLow: Bool,
        emailPreferencesEnabled: Bool,
        isDemoMode: Bool,
        isNewConversationFromInboxEnabled: Bool,
        isPuppyGuideEnabled: Bool,
        isResumeClaimEnabled: Bool,
        isOnboardingEnabled: Bool,
        isTerminationRedirectionEnabled: Bool,
        isAnalyticsEnabled: Bool,
        isResumingOngoingShopSessionsEnabled: Bool,
        isCancelInsuranceHiddenFromHomeScreen: Bool
    ) {
        self.isUpdateNecessary = isUpdateNecessary
        self.osVersionTooLow = osVersionTooLow
        self.emailPreferencesEnabled = emailPreferencesEnabled
        self.isDemoMode = isDemoMode
        self.isNewConversationFromInboxEnabled = isNewConversationFromInboxEnabled
        self.isPuppyGuideEnabled = isPuppyGuideEnabled
        self.isResumeClaimEnabled = isResumeClaimEnabled
        self.isOnboardingEnabled = isOnboardingEnabled
        self.isTerminationRedirectionEnabled = isTerminationRedirectionEnabled
        self.isAnalyticsEnabled = isAnalyticsEnabled
        self.isResumingOngoingShopSessionsEnabled = isResumingOngoingShopSessionsEnabled
        self.isCancelInsuranceHiddenFromHomeScreen = isCancelInsuranceHiddenFromHomeScreen
    }
}

public enum PaymentType {
    case trustly
}
