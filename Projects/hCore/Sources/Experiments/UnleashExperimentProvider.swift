import Combine
import Foundation

/// Reports the member's experiment variants as Unleash assigns them, see `ExperimentDefinition`.
///
/// A variant is only reported from toggles fetched for the current member, since Unleash assigns it from the
/// member id the fetch carried: `FeatureData.experiments` is nil until those are in hand. Right after a login, or
/// on a first launch, `activeExperiments()` waits for the member's own fetch for at most `memberStateTimeout`,
/// after which it reports no experiments and the member keeps today's behaviour. Once a wait has timed out, later
/// calls answer at once until the flags change, so an unreachable Unleash delays one request rather than every one.
///
/// The variants are also set as Firebase user properties so every analytics event carries them, following every
/// flag update, which includes the member in the Unleash context changing on login and logout. Firebase uploads
/// nothing while collection is disabled, so no consent gating is needed here.
@MainActor
public final class UnleashExperimentProvider: ExperimentProvider {
    static let userPropertyExperimentName = "experiment_name"
    static let userPropertyExperimentVariant = "experiment_variant"

    @Inject private var eventTrackingClient: EventTrackingClient
    private let featureFlags: FeatureFlags
    private let memberStateTimeout: TimeInterval
    private var userPropertiesCancellable: AnyCancellable?
    /// Set when a wait timed out, cleared by the next flag update since that may be the member's toggles arriving.
    private var hasTimedOutSinceLastUpdate = false

    public init(featureFlags: FeatureFlags = .shared, memberStateTimeout: TimeInterval = 3) {
        self.featureFlags = featureFlags
        self.memberStateTimeout = memberStateTimeout
        userPropertiesCancellable = featureFlags.publisher(for: \.data)
            .handleEvents(receiveOutput: { [weak self] _ in self?.hasTimedOutSinceLastUpdate = false })
            // Toggles that aren't the member's own say nothing about their group. Publishing from them would clear
            // the properties Firebase kept from the last session, leaving events without the group until the
            // member's fetch lands.
            .compactMap(\.experiments)
            .removeDuplicates()
            .sink { [weak self] experiments in self?.publishUserProperties(experiments) }
    }

    public func activeExperiments() async -> [Experiment] {
        if let experiments = featureFlags.experiments {
            return experiments
        }
        if !hasTimedOutSinceLastUpdate {
            let arrived = await waitForTheMembersExperiments()
            if !arrived {
                hasTimedOutSinceLastUpdate = true
            }
        }
        return featureFlags.experiments ?? []
    }

    /// Whether the member's experiments arrived within `memberStateTimeout`.
    private func waitForTheMembersExperiments() async -> Bool {
        await withCheckedContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = featureFlags.publisher(for: \.data)
                .compactMap(\.experiments)
                .map { _ in true }
                .timeout(.seconds(memberStateTimeout), scheduler: RunLoop.main)
                .first()
                .replaceEmpty(with: false)
                .sink { arrived in
                    continuation.resume(returning: arrived)
                    cancellable = nil
                }
        }
    }

    // Two properties hold one experiment at a time, which is all that is running. Cleared when the member is in none.
    private func publishUserProperties(_ experiments: [Experiment]) {
        let experiment = experiments.first
        eventTrackingClient.setUserProperty(name: Self.userPropertyExperimentName, value: experiment?.name)
        eventTrackingClient.setUserProperty(name: Self.userPropertyExperimentVariant, value: experiment?.variant)
    }
}
