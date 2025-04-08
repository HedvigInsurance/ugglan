import Foundation
import UnleashProxyClientSwift
import hGraphQL

public class FeatureFlagsUnleash: FeatureFlags {
    private var unleashClient: UnleashClient?
    private var environment: Environment

    public init(
        environment: Environment
    ) {
        self.environment = environment
    }
    public var isDemoMode: Bool = false
    public var isConversationBasedMessagesEnabled: Bool = false
    public var isEditCoInsuredEnabled: Bool = false
    public var isTravelInsuranceEnabled: Bool = false
    public var isTerminationFlowEnabled: Bool = false
    public var isUpdateNecessary: Bool = false
    public var isChatDisabled: Bool = false
    public var isPaymentScreenEnabled: Bool = false
    public var isCommonClaimEnabled: Bool = false
    public var isForeverEnabled: Bool = false
    public var isConnectPaymentEnabled: Bool = true
    public var isHelpCenterEnabled: Bool = false
    public var isSubmitClaimEnabled: Bool = true
    public var osVersionTooLow: Bool = false
    public var emailPreferencesEnabled: Bool = false
    public var isAddonsEnabled: Bool = false
    public var isMovingFlowEnabled: Bool = false
    public var isAddonsRemovalFromMovingFlowEnabled: Bool = false
    public var isRedeemCampaignDisabled: Bool = false

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

        do {
            try await self.unleashClient?.start(printToConsole: true)
            handleUpdate()
            log.info("Successfully loaded unleash experiments")
        } catch let exception {
            log.info("Failed loading unleash experiments \(exception)")
        }
        self.unleashClient?
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

    private func handleReady() {
        setFeatureFlags()
    }

    private func handleUpdate() {
        setFeatureFlags()
    }

    private func setFeatureFlags() {
        guard let unleashClient else {
            return
        }
        var featureFlags = [String: Bool]()

        let editCoInsuredKey = "edit_coinsured"
        isEditCoInsuredEnabled = unleashClient.isEnabled(name: editCoInsuredKey)
        featureFlags[editCoInsuredKey] = isEditCoInsuredEnabled

        let travelInsuranceKey = "travel_insurance"
        isTravelInsuranceEnabled = unleashClient.isEnabled(name: travelInsuranceKey)
        featureFlags[travelInsuranceKey] = isTravelInsuranceEnabled

        let terminationFlowKey = "termination_flow"
        isTerminationFlowEnabled = unleashClient.isEnabled(name: terminationFlowKey)
        featureFlags[terminationFlowKey] = isTerminationFlowEnabled

        let updateNecessaryKey = "update_necessary"
        isUpdateNecessary = unleashClient.isEnabled(name: updateNecessaryKey)
        featureFlags[updateNecessaryKey] = isUpdateNecessary

        let osVersionTooLowKey = "update_os_version"
        osVersionTooLow = unleashClient.isEnabled(name: osVersionTooLowKey)
        featureFlags[osVersionTooLowKey] = osVersionTooLow

        let disableChatKey = "disable_chat"
        isChatDisabled = unleashClient.isEnabled(name: disableChatKey)
        featureFlags[disableChatKey] = isChatDisabled

        let paymentScreenKey = "payment_screen"
        isPaymentScreenEnabled = unleashClient.isEnabled(name: paymentScreenKey)
        featureFlags[paymentScreenKey] = isPaymentScreenEnabled

        let helpCenterKey = "help_center"
        isHelpCenterEnabled = unleashClient.isEnabled(name: helpCenterKey)
        featureFlags[helpCenterKey] = isHelpCenterEnabled

        let enableAddonsKey = "enable_addons"
        isAddonsEnabled = unleashClient.isEnabled(name: enableAddonsKey)
        featureFlags[enableAddonsKey] = isAddonsEnabled

        let paymentTypeKey = "payment_type"
        let paymentTypeName = unleashClient.getVariant(name: paymentTypeKey).name
        if paymentTypeName == "trustly" {
            isConnectPaymentEnabled = true
        } else {
            isConnectPaymentEnabled = false
        }
        let movingFlowKey = "moving_flow"
        isMovingFlowEnabled = unleashClient.isEnabled(name: movingFlowKey)
        featureFlags[movingFlowKey] = isMovingFlowEnabled

        let enableAddonsRemovalFromMovingFlowKey = "enable_addons_removal_from_moving_flow"
        isAddonsRemovalFromMovingFlowEnabled = unleashClient.isEnabled(name: movingFlowKey)
        featureFlags[enableAddonsRemovalFromMovingFlowKey] = isAddonsRemovalFromMovingFlowEnabled

        let disableRedeemCampaignKey = "disable_redeem_campaign"
        isRedeemCampaignDisabled = unleashClient.isEnabled(name: disableRedeemCampaignKey)
        featureFlags[disableRedeemCampaignKey] = isRedeemCampaignDisabled

        Task {
            log.info(
                "Feature flag set",
                attributes: ["featureFlags": featureFlags]
            )
        }
    }
}
