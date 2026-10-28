import Combine
import Foundation

/// Reports the member's experiment variants as Unleash assigns them, see `FeatureFlagsUnleash`.
///
/// Variants only count from toggles fetched for the current member. Until those land, `activeExperiments()` waits
/// up to `memberStateTimeout` and then reports none.
///
/// Each experiment is also set as a Firebase user property named after it, holding the variant, so every analytics
/// event carries it. Firebase uploads nothing while collection is disabled, so no consent gating is needed here.
@MainActor
public final class UnleashExperimentProvider: ExperimentProvider {
    @Inject private var eventTrackingClient: EventTrackingClient
    private let featureFlags: FeatureFlags
    private let memberStateTimeout: TimeInterval
    private var userPropertiesCancellable: AnyCancellable?

    public init(featureFlags: FeatureFlags = .shared, memberStateTimeout: TimeInterval = 3) {
        self.featureFlags = featureFlags
        self.memberStateTimeout = memberStateTimeout
        userPropertiesCancellable = featureFlags.publisher(for: \.data)
            // Toggles that aren't the member's say nothing about their group, and would clear the one Firebase
            // kept from the last session.
            .compactMap(\.experiments)
            .removeDuplicates()
            .sink { [weak self] experiments in self?.publishUserProperties(experiments) }
    }

    public func activeExperiments() async -> [Experiment] {
        do {
            try await waitForTheMembersExperiments()
        } catch {
            // Sizes how often a cross-sell query goes out without the member's variant.
            log.warn("Gave up waiting \(memberStateTimeout)s for the member's experiments, reporting none")
        }
        return featureFlags.experiments ?? []
    }

    /// Waits until the member's experiments arrive. Throws `CancellationError` if `memberStateTimeout` passes first.
    private func waitForTheMembersExperiments() async throws {
        let featureFlags = featureFlags
        let memberStateTimeout = memberStateTimeout
        // Suspends until the flag is first true. Only the timeout cancelling the task ends the loop without a value.
        // The check sits in the loop rather than in a Combine `filter`: `AsyncPublisher` pulls values off the main
        // actor, so a closure in the chain would inherit main-actor isolation and trap when Combine calls it.
        let arrival = Task {
            for await hasFetched in featureFlags.publisher(for: \.hasFetchedInitialDataForMember).values
            where hasFetched {
                return
            }
            throw CancellationError()
        }
        let timeout = Task {
            await delay(memberStateTimeout)
            arrival.cancel()
        }
        defer { timeout.cancel() }
        try await arrival.value
    }

    private func publishUserProperties(_ experiments: [Experiment]) {
        for experiment in experiments {
            eventTrackingClient.setUserProperty(name: experiment.name, value: experiment.variant)
        }
    }
}
