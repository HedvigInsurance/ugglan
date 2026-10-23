import Combine
import Environment
import Foundation
import UnleashProxyClientSwift

public class FeatureFlagsUnleash: FeatureFlagsClient {
    private var featureDataPublisher = PassthroughSubject<FeatureData, Never>()

    public var featureData: AnyPublisher<FeatureData, Never> {
        featureDataPublisher.eraseToAnyPublisher()
    }

    private var unleashClient: UnleashClient?
    private var environment: Environment
    private let pollerSession: PollerSession
    /// The context the client currently fetches for. Unleash resolves strategies server-side against the context a
    /// fetch carried, so toggles fetched for another member, or for no member, resolve every member-dependent
    /// strategy wrongly for this one.
    private var contextInEffect: [String: String] = [:]
    /// The context the toggles in hand were fetched for, or nil until the first fetch lands.
    private var fetchedContext: [String: String]?
    private var contextUpdateTask: Task<Void, Never>?

    public init(
        environment: Environment,
        pollerSession: PollerSession = URLSession.shared
    ) {
        self.environment = environment
        self.pollerSession = pollerSession
    }

    public func setup(with context: [String: String]) async throws {
        contextUpdateTask?.cancel()
        contextInEffect = context
        fetchedContext = nil
        // Login runs this again with the member in the context while Home is already querying cross-sells, so
        // the toggles in hand must stop counting as this member's before the new client has fetched anything.
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
        contextUpdateTask?.cancel()
        contextUpdateTask = Task { [weak self] in
            do {
                try await client.updateContext(context: context)
                guard let self, !Task.isCancelled, self.unleashClient === client else { return }
                // A 304 lands here too and posts no event: the SDK keeps one ETag across contexts and writes
                // nothing on one, and it means the toggles in hand are exactly what Unleash resolves for this context.
                self.fetchedContext = context
                self.setFeatureFlags()
            } catch {
                log.info("Failed updating unleash context \(error)")
            }
        }
    }

    private func handleUpdate() {
        // The SDK fetches for the context it holds, which it takes before fetching, so an update is for the
        // context in effect.
        fetchedContext = contextInEffect
        setFeatureFlags()
    }

    private func setFeatureFlags() {
        guard let unleashClient else {
            return
        }
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
            experiments: experimentsForCurrentMember(unleashClient)
        )
        featureDataPublisher.send(data)
    }

    /// The experiments the member is in, or nil while the toggles in hand were not fetched for the context in
    /// effect, since Unleash assigns variants server-side from the member id the fetch carried.
    private func experimentsForCurrentMember(_ client: UnleashClient) -> [Experiment]? {
        guard fetchedContext == contextInEffect else { return nil }
        return Experiment.active { flag in
            guard client.isEnabled(name: flag) else { return nil }
            let variant = client.getVariant(name: flag)
            return variant.enabled ? variant.name : nil
        }
    }
}
