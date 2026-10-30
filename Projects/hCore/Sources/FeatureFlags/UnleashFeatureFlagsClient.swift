import Combine
import Environment
import Foundation
import UnleashProxyClientSwift

public class UnleashFeatureFlagsClient: FeatureFlagsClient {
    private var featureDataPublisher = PassthroughSubject<FeatureData, Never>()

    public var featureData: AnyPublisher<FeatureData, Never> {
        featureDataPublisher.eraseToAnyPublisher()
    }

    private var unleashClient: UnleashClient?
    private var environment: Environment
    private let pollerSession: PollerSession
    private let memberStateTimeout: TimeInterval
    /// The context the client fetches for. Unleash resolves strategies against the context a fetch carried.
    private var contextInEffect: [String: String] = [:]
    /// The context the toggles in hand were fetched for, nil until the first fetch lands.
    private var fetchedContext: [String: String]?
    /// Nil while the toggles in hand were fetched for another context.
    private(set) var experiments: [Experiment]?
    /// Nil while the toggles in hand are not the logged-in member's.
    private let memberExperiments = CurrentValueSubject<[Experiment]?, Never>(nil)
    /// Failed setups are retried with the same context, so only a change is worth waiting for again.
    private var contextsAtLastTimeout: ContextsState?

    public init(
        environment: Environment,
        pollerSession: PollerSession = URLSession.shared,
        memberStateTimeout: TimeInterval = 3
    ) {
        self.environment = environment
        self.pollerSession = pollerSession
        self.memberStateTimeout = memberStateTimeout
    }

    public func setup(with context: [String: String]) async throws {
        contextInEffect = context
        fetchedContext = nil
        // Login runs this again while Home already queries cross-sells: the toggles in hand are not this member's.
        setFeatureFlags()
        unleashClient?.unsubscribe(name: "ready")
        unleashClient?.unsubscribe(name: "update")
        unleashClient?.stop()
        var clientKey: String {
            switch environment {
            case .production:
                return "*:production.21d6af57ae16320fde3a3caf024162db19cc33bf600ab7439c865c20"
            default:
                return "*:development.f2455340ac9d599b5816fa879d079f21dd0eb03e4315130deb5377b6"
            }
        }
        let environmentContext = clientKey.replacingOccurrences(of: "*:", with: "").components(separatedBy: ".")[0]
        let client = UnleashProxyClientSwift.UnleashClient(
            unleashUrl: "https://eu.app.unleash-hosted.com/eubb1047/api/frontend",
            clientKey: clientKey,
            refreshInterval: 60 * 60,
            appName: "ios",
            environment: environmentContext,
            context: context,
            pollerSession: pollerSession
        )
        unleashClient = client

        log.info("Started loading unleash experiments")

        try await client.start(printToConsole: true)
        // A later setup may have replaced this client while its fetch was in flight.
        guard unleashClient === client else { return }
        fetchedContext = context
        setFeatureFlags()
        log.info("Successfully loaded unleash experiments")
        client.subscribe(.update) { [weak self] in
            self?.handleUpdate()
        }
    }

    public func updateContext(context: [String: String]) {
        guard let client = unleashClient, context != contextInEffect else { return }
        contextInEffect = context
        // Until the fetch for this context lands, the toggles in hand say nothing about this member.
        setFeatureFlags()
        Task { [weak self] in
            do {
                try await client.updateContext(context: context)
                // A later setup or context change may have taken over while this fetch was in flight.
                guard let self, self.unleashClient === client, self.contextInEffect == context else { return }
                // A 304 lands here too without an update event, and means the toggles in hand are this context's.
                self.fetchedContext = context
                self.setFeatureFlags()
            } catch {
                log.info("Failed updating unleash context \(error)")
            }
        }
    }

    private func handleUpdate() {
        // The SDK only fetches for the context it holds, which is the one in effect.
        fetchedContext = contextInEffect
        setFeatureFlags()
    }

    private func setFeatureFlags() {
        guard let unleashClient else {
            return
        }
        experiments = experimentsForCurrentMember(unleashClient)
        memberExperiments.send(contextInEffect[FeatureFlags.userId] != nil ? experiments : nil)
        let data = FeatureData(
            isUpdateNecessary: unleashClient.isEnabled(name: "update_necessary"),
            isSubmitClaimEnabled: true,
            osVersionTooLow: unleashClient.isEnabled(name: "update_os_version"),
            emailPreferencesEnabled: true,
            isDemoMode: false,
            isAddonsRemovalFromMovingFlowEnabled: unleashClient.isEnabled(
                name: "enable_addons_removal_from_moving_flow"
            ),
            isNewConversationFromInboxEnabled: unleashClient.isEnabled(
                name: "enable_new_conversation_from_inbox"
            ),
            isPuppyGuideEnabled: !unleashClient.isEnabled(name: "disable_puppy_guide"),
            isResumeClaimEnabled: unleashClient.isEnabled(name: "enable_claim_intent_resume"),
            isOnboardingEnabled: !unleashClient.isEnabled(name: "disable_onboarding"),
            isTerminationRedirectionEnabled: !unleashClient.isEnabled(name: "disable_termination_redirection"),
            isAnalyticsEnabled: !unleashClient.isEnabled(name: "disable_analytics"),
            isResumingOngoingShopSessionsEnabled: !unleashClient.isEnabled(
                name: "disable_resuming_ongoing_shop_sessions"
            ),
            showYearInReview: unleashClient.isEnabled(
                name: "year_in_review"
            )
        )
        featureDataPublisher.send(data)
    }
}

/// Waits up to `memberStateTimeout` for the member's toggles, then reports none. After a timeout it answers at once
/// until the context changes, so an unreachable Unleash delays one request rather than every one.
extension UnleashFeatureFlagsClient: ExperimentProvider {
    public func activeExperiments() async -> [Experiment] {
        let contextsBeforeWaiting = currentContexts
        if contextsBeforeWaiting != contextsAtLastTimeout {
            do {
                return try await waitForTheMembersExperiments()
            } catch {
                contextsAtLastTimeout = contextsBeforeWaiting
                log.warn("Gave up waiting \(memberStateTimeout)s for the member's experiments, reporting none")
            }
        }
        return memberExperiments.value ?? []
    }

    private var currentContexts: ContextsState {
        ContextsState(inEffect: contextInEffect, fetched: fetchedContext)
    }

    /// Throws `CancellationError` if `memberStateTimeout` passes first.
    private func waitForTheMembersExperiments() async throws -> [Experiment] {
        if let experiments = memberExperiments.value { return experiments }
        let memberExperiments = memberExperiments
        let memberStateTimeout = memberStateTimeout
        // Filtered in the loop, not with `compactMap`: `AsyncPublisher` pulls values off the main actor, so a
        // main-actor-isolated closure in the chain would trap.
        let arrival = Task {
            for await experiments in memberExperiments.values {
                if let experiments { return experiments }
            }
            throw CancellationError()
        }
        let timeout = Task {
            await delay(memberStateTimeout)
            arrival.cancel()
        }
        defer { timeout.cancel() }
        return try await arrival.value
    }

    /// Each experiment's name as the backend knows it, and the Unleash flag assigning its variant.
    fileprivate static let knownExperiments: [(name: String, unleashFlag: String)] = [
        // Variants DISCOUNT_50 (today's behaviour) and NO_DISCOUNT. The backend withholds the discount for
        // NO_DISCOUNT.
        (name: "ACCIDENT_DISCOUNT", unleashFlag: "accident_discount_experiment")
    ]

    fileprivate func experimentsForCurrentMember(_ client: UnleashClient) -> [Experiment]? {
        guard fetchedContext == contextInEffect else { return nil }
        return Experiment.active(in: Self.knownExperiments) { flag in
            guard client.isEnabled(name: flag) else { return nil }
            let variant = client.getVariant(name: flag)
            return variant.enabled ? variant.name : nil
        }
    }
}

private struct ContextsState: Equatable {
    let inEffect: [String: String]
    let fetched: [String: String]?
}
