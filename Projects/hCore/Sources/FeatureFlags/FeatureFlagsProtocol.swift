import Combine
import Foundation
import Observation

@MainActor
public protocol FeatureFlagsClient {
    var featureData: AnyPublisher<FeatureData, Never> { get }
    func setup(with context: [String: String]) async throws
    func updateContext(context: [String: String])
}

public struct FeatureData: Codable, Equatable {
    public let isUpdateNecessary: Bool
    public let isSubmitClaimEnabled: Bool
    public let osVersionTooLow: Bool
    public let emailPreferencesEnabled: Bool
    public let isDemoMode: Bool
    public let isAddonsRemovalFromMovingFlowEnabled: Bool
    public let isNewConversationFromInboxEnabled: Bool
    public let isPuppyGuideEnabled: Bool
    public let isResumeClaimEnabled: Bool
    public let isOnboardingEnabled: Bool
    public let isTerminationRedirectionEnabled: Bool
    public let isAnalyticsEnabled: Bool
    public let isResumingOngoingShopSessionsEnabled: Bool
    /// The member's experiments, empty when they are in none, or nil while the toggles in hand are not theirs.
    public let experiments: [Experiment]?

    public init(
        isUpdateNecessary: Bool,
        isSubmitClaimEnabled: Bool,
        osVersionTooLow: Bool,
        emailPreferencesEnabled: Bool,
        isDemoMode: Bool,
        isAddonsRemovalFromMovingFlowEnabled: Bool,
        isNewConversationFromInboxEnabled: Bool,
        isPuppyGuideEnabled: Bool,
        isResumeClaimEnabled: Bool,
        isOnboardingEnabled: Bool,
        isTerminationRedirectionEnabled: Bool,
        isAnalyticsEnabled: Bool,
        isResumingOngoingShopSessionsEnabled: Bool,
        experiments: [Experiment]? = nil
    ) {
        self.isUpdateNecessary = isUpdateNecessary
        self.isSubmitClaimEnabled = isSubmitClaimEnabled
        self.osVersionTooLow = osVersionTooLow
        self.emailPreferencesEnabled = emailPreferencesEnabled
        self.isDemoMode = isDemoMode
        self.isAddonsRemovalFromMovingFlowEnabled = isAddonsRemovalFromMovingFlowEnabled
        self.isNewConversationFromInboxEnabled = isNewConversationFromInboxEnabled
        self.isPuppyGuideEnabled = isPuppyGuideEnabled
        self.isResumeClaimEnabled = isResumeClaimEnabled
        self.isOnboardingEnabled = isOnboardingEnabled
        self.isTerminationRedirectionEnabled = isTerminationRedirectionEnabled
        self.isAnalyticsEnabled = isAnalyticsEnabled
        self.isResumingOngoingShopSessionsEnabled = isResumingOngoingShopSessionsEnabled
        self.experiments = experiments
    }
}

extension FeatureData {
    func with(experiments: [Experiment]?) -> FeatureData {
        FeatureData(
            isUpdateNecessary: isUpdateNecessary,
            isSubmitClaimEnabled: isSubmitClaimEnabled,
            osVersionTooLow: osVersionTooLow,
            emailPreferencesEnabled: emailPreferencesEnabled,
            isDemoMode: isDemoMode,
            isAddonsRemovalFromMovingFlowEnabled: isAddonsRemovalFromMovingFlowEnabled,
            isNewConversationFromInboxEnabled: isNewConversationFromInboxEnabled,
            isPuppyGuideEnabled: isPuppyGuideEnabled,
            isResumeClaimEnabled: isResumeClaimEnabled,
            isOnboardingEnabled: isOnboardingEnabled,
            isTerminationRedirectionEnabled: isTerminationRedirectionEnabled,
            isAnalyticsEnabled: isAnalyticsEnabled,
            isResumingOngoingShopSessionsEnabled: isResumingOngoingShopSessionsEnabled,
            experiments: experiments
        )
    }
}

public enum PaymentType {
    case trustly
}

@MainActor
extension Dependencies {
    public static func featureFlags() -> FeatureFlags {
        let featureFlags: FeatureFlags = shared.resolve()
        return featureFlags
    }
}

@MainActor
@dynamicMemberLookup
@Observable
public class FeatureFlags {
    @ObservationIgnored public static let shared = FeatureFlags()
    @ObservationIgnored private var client: FeatureFlagsClient?
    @ObservationIgnored private var featureDataCancellable: AnyCancellable?
    public var data: FeatureData = .init(
        isUpdateNecessary: false,
        isSubmitClaimEnabled: false,
        osVersionTooLow: false,
        emailPreferencesEnabled: false,
        isDemoMode: false,
        isAddonsRemovalFromMovingFlowEnabled: false,
        isNewConversationFromInboxEnabled: false,
        isPuppyGuideEnabled: false,
        isResumeClaimEnabled: false,
        isOnboardingEnabled: false,
        isTerminationRedirectionEnabled: false,
        isAnalyticsEnabled: false,
        isResumingOngoingShopSessionsEnabled: false
    )

    public var hasFetchedInitialData = false
    /// The Unleash context last handed to the client, which carries the member.
    @ObservationIgnored private(set) var context: [String: String] = [:]

    public subscript<T>(dynamicMember keyPath: KeyPath<FeatureData, T>) -> T {
        data[keyPath: keyPath]
    }

    private init() {}

    public func setup(with context: [String: String]) async throws {
        let client: FeatureFlagsClient = Dependencies.shared.resolve()
        self.context = context
        // After a logout the client is fresh and publishes nothing until it fetches, so drop the old member's.
        data = data.with(experiments: nil)
        featureDataCancellable = client.featureData
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] data in
                guard let self = self else { return }
                Task {
                    log.info(
                        "Feature flag set",
                        attributes: ["featureFlags": data]
                    )
                }
                self.data = data
                self.hasFetchedInitialData = true
            }
        self.client = client
        try await client.setup(with: context)
    }

    public func updateContext(context: [String: String]) {
        self.context = context
        client?.updateContext(context: context)
    }
}
