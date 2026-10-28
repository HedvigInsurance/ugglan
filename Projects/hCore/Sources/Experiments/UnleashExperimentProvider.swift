import Combine
import Foundation

/// Reports the member's experiment variants as Unleash assigns them, see `FeatureFlagsUnleash`.
///
/// Variants only count from toggles fetched for the current member. Until those land, `activeExperiments()` waits
/// up to `memberStateTimeout` and then reports none. After a timeout it answers at once until the toggles or the
/// member change, so an unreachable Unleash delays one request rather than every one.
///
/// Analytics don't read the variants from here: the backend lists every experiment it applied in the offer's store
/// link, and the cross-sell events read them from there.
@MainActor
public final class UnleashExperimentProvider: ExperimentProvider {
    private let featureFlags: FeatureFlags
    private let memberStateTimeout: TimeInterval
    /// What the flags held when a wait last timed out. A failed Unleash setup is retried every second and
    /// republishes the same toggles, so only a real change is worth waiting for again.
    private var flagsAtLastTimeout: FlagsState?

    public init(featureFlags: FeatureFlags = .shared, memberStateTimeout: TimeInterval = 3) {
        self.featureFlags = featureFlags
        self.memberStateTimeout = memberStateTimeout
    }

    public func activeExperiments() async -> [Experiment] {
        let flagsBeforeWaiting = currentFlags
        if flagsBeforeWaiting != flagsAtLastTimeout {
            do {
                try await waitForTheMembersExperiments()
            } catch {
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
}

private struct FlagsState: Equatable {
    let data: FeatureData
    let context: [String: String]
}
