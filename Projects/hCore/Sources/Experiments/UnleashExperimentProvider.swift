import Combine
import Foundation

/// Reports the member's experiment variants as Unleash assigns them, see `ExperimentDefinition`.
///
/// Variants only count from toggles fetched for the current member. Until those land, `activeExperiments()` waits
/// up to `memberStateTimeout` and then reports none. After a timeout it answers at once until the toggles or the
/// member change, so an unreachable Unleash delays one request rather than every one.
///
/// The variants are mirrored to Firebase user properties so every analytics event carries them. Firebase uploads
/// nothing while collection is disabled, so no consent gating is needed here.
@MainActor
public final class UnleashExperimentProvider: ExperimentProvider {
    static let userPropertyExperimentName = "experiment_name"
    static let userPropertyExperimentVariant = "experiment_variant"

    @Inject private var eventTrackingClient: EventTrackingClient
    private let featureFlags: FeatureFlags
    private let memberStateTimeout: TimeInterval
    private var userPropertiesCancellable: AnyCancellable?
    /// What the flags held when a wait last timed out. A failed Unleash setup is retried every second and
    /// republishes the same toggles, so only a real change is worth waiting for again.
    private var flagsAtLastTimeout: FlagsState?

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
        if let experiments = featureFlags.experiments {
            return experiments
        }
        let flagsBeforeWaiting = currentFlags
        if flagsBeforeWaiting != flagsAtLastTimeout {
            let arrived = await waitForTheMembersExperiments()
            if !arrived {
                flagsAtLastTimeout = flagsBeforeWaiting
                // Sizes how often a cross-sell query goes out without the member's variant.
                log.warn("Gave up waiting \(memberStateTimeout)s for the member's experiments, reporting none")
            }
        }
        return featureFlags.experiments ?? []
    }

    private var currentFlags: FlagsState {
        FlagsState(data: featureFlags.data, context: featureFlags.context)
    }

    /// Whether the member's experiments arrived within `memberStateTimeout`.
    private func waitForTheMembersExperiments() async -> Bool {
        let featureFlags = featureFlags
        let memberStateTimeout = memberStateTimeout
        let arrival = Task {
            for await _ in featureFlags.publisher(for: \.data).compactMap(\.experiments).values {
                return true
            }
            return false
        }
        let timeout = Task {
            try? await Task.sleep(for: .seconds(memberStateTimeout))
            arrival.cancel()
        }
        defer { timeout.cancel() }
        return await arrival.value
    }

    // Two properties hold one experiment at a time, which is all that is running. Cleared when the member is in none.
    private func publishUserProperties(_ experiments: [Experiment]) {
        let experiment = experiments.first
        eventTrackingClient.setUserProperty(name: Self.userPropertyExperimentName, value: experiment?.name)
        eventTrackingClient.setUserProperty(name: Self.userPropertyExperimentVariant, value: experiment?.variant)
    }
}

private struct FlagsState: Equatable {
    let data: FeatureData
    let context: [String: String]
}
