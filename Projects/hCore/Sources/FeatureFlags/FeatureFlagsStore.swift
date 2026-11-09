import AppStateContainer
import Combine
import Foundation
import Observation

@MainActor
extension Dependencies {
    public static func featureFlags() -> FeatureFlagsStore {
        globalAppStateContainer.get()
    }
}

@MainActor
@dynamicMemberLookup
@PersistableStore
@Observable
public final class FeatureFlagsStore: AppStore {
    public static let userId = "userId"

    @ObservationIgnored @Transient private var client: FeatureFlagsClient?
    @ObservationIgnored @Transient private var featureDataCancellable: AnyCancellable?
    /// What Unleash sent this session; nil until the first fetch lands.
    @Transient private var fetchedData: FeatureData?
    /// The persisted copy of the last fetch, used until this session's fetch lands.
    private var savedData: FeatureData?

    public var data: FeatureData {
        get { fetchedData ?? savedData?.withoutUpdateGates ?? .allDisabled }
        set {
            fetchedData = newValue
            savedData = newValue
        }
    }

    @Transient public var hasFetchedInitialData: Bool = false

    public subscript<T>(dynamicMember keyPath: KeyPath<FeatureData, T>) -> T {
        data[keyPath: keyPath]
    }

    public init() {}

    public func setup(with context: [String: String]) async throws {
        let client: FeatureFlagsClient = Dependencies.shared.resolve()
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
        client?.updateContext(context: context)
    }
}

extension FeatureData {
    fileprivate static let allDisabled = FeatureData(
        isUpdateNecessary: false,
        osVersionTooLow: false,
        emailPreferencesEnabled: false,
        isDemoMode: false,
        isNewConversationFromInboxEnabled: false,
        isPuppyGuideEnabled: false,
        isResumeClaimEnabled: false,
        isOnboardingEnabled: false,
        isTerminationRedirectionEnabled: false,
        isAnalyticsEnabled: false,
        isResumingOngoingShopSessionsEnabled: false,
        isCancelInsuranceHiddenFromHomeScreen: false
    )

    /// A saved `isUpdateNecessary` / `osVersionTooLow` may predate an app or OS update, and would block the app
    /// behind an update screen until Unleash answers, so those two only ever come from a fresh fetch.
    fileprivate var withoutUpdateGates: FeatureData {
        FeatureData(
            isUpdateNecessary: false,
            osVersionTooLow: false,
            emailPreferencesEnabled: emailPreferencesEnabled,
            isDemoMode: isDemoMode,
            isNewConversationFromInboxEnabled: isNewConversationFromInboxEnabled,
            isPuppyGuideEnabled: isPuppyGuideEnabled,
            isResumeClaimEnabled: isResumeClaimEnabled,
            isOnboardingEnabled: isOnboardingEnabled,
            isTerminationRedirectionEnabled: isTerminationRedirectionEnabled,
            isAnalyticsEnabled: isAnalyticsEnabled,
            isResumingOngoingShopSessionsEnabled: isResumingOngoingShopSessionsEnabled,
            isCancelInsuranceHiddenFromHomeScreen: isCancelInsuranceHiddenFromHomeScreen
        )
    }
}
