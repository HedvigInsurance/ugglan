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

    public var isConversationBasedMessagesEnabled: Bool = false
    public var loadingExperimentsSuccess: (Bool) -> Void = { _ in }
    public var isMovingFlowEnabled: Bool = false
    public var isEditCoInsuredEnabled: Bool = false
    public var isTravelInsuranceEnabled: Bool = false
    public var isTerminationFlowEnabled: Bool = false
    public var isUpdateNecessary: Bool = false
    public var isChatDisabled: Bool = false
    public var isPaymentScreenEnabled: Bool = false
    public var isCommonClaimEnabled: Bool = false
    public var isForeverEnabled: Bool = false
    public var paymentType: PaymentType = .trustly
    public var isHelpCenterEnabled: Bool = false
    public var isSubmitClaimEnabled: Bool = true
    public var osVersionTooLow: Bool = false
    public var emailPreferencesEnabled: Bool = false
    public var isTiersEnabled: Bool = false
    public func setup(with context: [String: String], onComplete: @escaping (_ success: Bool) -> Void) {
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
        loadingExperimentsSuccess = onComplete
        unleashClient = UnleashProxyClientSwift.UnleashClient(
            unleashUrl: "https://eu.app.unleash-hosted.com/eubb1047/api/frontend",
            clientKey: clientKey,
            refreshInterval: 60 * 60,
            appName: "ios",
            environment: environmentContext,
            context: context
        )
        unleashClient?
            .subscribe(name: "ready") { [weak self] in
                self?.handleReady()
            }
        unleashClient?
            .subscribe(name: "update") { [weak self] in
                self?.handleUpdate()
            }
        startUnleash()
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

    private func startUnleash() {
        log.info("Started loading unleash experiments")
        emailPreferencesEnabled = Localization.Locale.currentLocale.value.market == .se
        unleashClient?
            .start(
                true,
                completionHandler: { [weak self] errorResponse in
                    guard errorResponse != nil else {
                        return
                    }
                    self?.loadingExperimentsSuccess(false)
                    log.info("Failed loading unleash experiments")
                }
            )
    }

    private func handleReady() {
        setFeatureFlags()
        loadingExperimentsSuccess(true)
        log.info("Successfully loaded unleash experiments")
    }

    private func handleUpdate() {
        setFeatureFlags()
    }

    private func setFeatureFlags() {
        guard let unleashClient else {
            return
        }
        var featureFlags = [String: Bool]()

        let movingFlowKey = "moving_flow"
        isMovingFlowEnabled = unleashClient.isEnabled(name: movingFlowKey)
        featureFlags[movingFlowKey] = isMovingFlowEnabled

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

        let enableTiersKey = "enable_tiers"
        isTiersEnabled = unleashClient.isEnabled(name: enableTiersKey)
        featureFlags[enableTiersKey] = isTiersEnabled

        let paymentTypeKey = "payment_type"
        let paymentTypeName = unleashClient.getVariant(name: paymentTypeKey).name
        if paymentTypeName == "adyen" {
            paymentType = .adyen
        } else {
            paymentType = .trustly
        }

        log.info(
            "Feature flag set",
            attributes: ["featureFlags": featureFlags]
        )
    }
}
