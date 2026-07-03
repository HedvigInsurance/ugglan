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
    public init(
        environment: Environment
    ) {
        self.environment = environment
    }

    public func setup(with context: [String: String]) async throws {
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
        unleashClient = UnleashProxyClientSwift.UnleashClient(
            unleashUrl: "https://eu.app.unleash-hosted.com/eubb1047/api/frontend",
            clientKey: clientKey,
            refreshInterval: 60 * 60,
            appName: "ios",
            environment: environmentContext,
            context: context
        )

        log.info("Started loading unleash experiments")

        try await unleashClient?.start(printToConsole: true)
        handleUpdate()
        log.info("Successfully loaded unleash experiments")
        unleashClient?
            .subscribe(.update) { [weak self] in
                self?.handleUpdate()
            }
    }

    public func updateContext(context: [String: String]) {
        if let existingContext = unleashClient?.context.toMap() {
            for contextKey in context.keys {
                if existingContext[contextKey] != context[contextKey] {
                    unleashClient?.updateContext(context: context)
                    break
                }
            }
        }
    }

    private func handleUpdate() {
        setFeatureFlags()
    }

    private func setFeatureFlags() {
        guard let unleashClient else {
            return
        }
        let data = FeatureData(
            isUpdateNecessary: unleashClient.isEnabled(name: "update_necessary"),
            isConnectPaymentEnabled: unleashClient.getVariant(name: "payment_type").name == "trustly",
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
            isResumeClaimEnabled: unleashClient.isEnabled(name: "enable_claim_intent_resume")
        )
        featureDataPublisher.send(data)
    }
}
