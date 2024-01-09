import Foundation
import UnleashProxyClientSwift
import hGraphQL

public protocol FeatureFlags {
    var loadingExperimentsSuccess: (Bool) -> Void { get set }
    var isMovingFlowEnabled: Bool { get set }
    var isEditCoInsuredEnabled: Bool { get set }
    var isTravelInsuranceEnabled: Bool { get set }
    var isTerminationFlowEnabled: Bool { get set }
    var isUpdateNecessary: Bool { get set }
    var isChatDisabled: Bool { get set }
    var isPaymentScreenEnabled: Bool { get set }
    var isCommonClaimEnabled: Bool { get set }
    var isForeverEnabled: Bool { get set }
    var paymentType: PaymentType { get set }
    var isHelpCenterEnabled: Bool { get set }

    func setup(with context: [String: String], onComplete: @escaping (_ success: Bool) -> Void)
    func updateContext(context: [String: String])
}

public enum PaymentType {
    case trustly
    case adyen
}

public class FeatureFlagsUnleash: FeatureFlags {
    private var unleashClient: UnleashClient?
    private var environment: Environment

    public init(
        environment: Environment
    ) {
        self.environment = environment
    }

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

        unleashClient = UnleashProxyClientSwift.UnleashClient(
            unleashUrl: "https://eu.app.unleash-hosted.com/eubb1047/api/frontend",
            clientKey: clientKey,
            refreshInterval: 60 * 60,
            appName: "ios",
            environment: environmentContext,
            context: context
        )
        startUnleash()
        unleashClient?.subscribe(name: "ready", callback: handleReady)
        unleashClient?.subscribe(name: "update", callback: handleUpdate)
        loadingExperimentsSuccess = onComplete
    }

    public func updateContext(context: [String: String]) {
        if unleashClient?.context.toMap() != context {
            unleashClient?.updateContext(context: context)
        }
    }

    private func startUnleash() {
        log.info("Started loading unleash experiments")
        unleashClient?
            .start(
                true,
                completionHandler: { errorResponse in
                    guard let errorResponse else {
                        return
                    }
                    self.loadingExperimentsSuccess(false)
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
        let movingFlowKey = "moving_flow"
        isMovingFlowEnabled = unleashClient.isEnabled(name: movingFlowKey)

        log.info(
            "feature flag info",
            attributes: [
                "flag": movingFlowKey,
                "enabled": isMovingFlowEnabled,
            ]
        )

        let editCoInsuredKey = "edit_coinsured"
        isEditCoInsuredEnabled = unleashClient.isEnabled(name: editCoInsuredKey)

        log.info(
            "feature flag info",
            attributes: [
                "flag": editCoInsuredKey,
                "enabled": isEditCoInsuredEnabled,
            ]
        )

        let travelInsuranceKey = "travel_insurance"
        isTravelInsuranceEnabled = unleashClient.isEnabled(name: travelInsuranceKey)
        log.info(
            "feature flag info",
            attributes: [
                "flag": travelInsuranceKey,
                "enabled": isTravelInsuranceEnabled,
            ]
        )

        let terminationFlowKey = "termination_flow"
        isTerminationFlowEnabled = unleashClient.isEnabled(name: terminationFlowKey)
        log.info(
            "feature flag info",
            attributes: [
                "flag": terminationFlowKey,
                "enabled": isTerminationFlowEnabled,
            ]
        )

        let updateNecessaryeKey = "update_necessary"
        isUpdateNecessary = unleashClient.isEnabled(name: updateNecessaryeKey)
        log.info(
            "feature flag info",
            attributes: [
                "flag": updateNecessaryeKey,
                "enabled": isUpdateNecessary,
            ]
        )

        let disableChatKey = "disable_chat"
        isChatDisabled = unleashClient.isEnabled(name: disableChatKey)
        log.info(
            "feature flag info",
            attributes: [
                "flag": disableChatKey,
                "enabled": isChatDisabled,
            ]
        )

        let paymentScreenKey = "payment_screen"
        isPaymentScreenEnabled = unleashClient.isEnabled(name: paymentScreenKey)
        log.info(
            "feature flag info",
            attributes: [
                "flag": paymentScreenKey,
                "enabled": isPaymentScreenEnabled,
            ]
        )

        let helpCenterKey = "help_center"
        isHelpCenterEnabled = unleashClient.isEnabled(name: helpCenterKey)
        log.info(
            "feature flag info",
            attributes: [
                "flag": helpCenterKey,
                "enabled": isHelpCenterEnabled,
            ]
        )

        let paymentTypeKey = "payment_type"
        let paymentTypeName = unleashClient.getVariant(name: paymentTypeKey).name
        if paymentTypeName == "adyen" {
            paymentType = .adyen
        } else {
            paymentType = .trustly
        }
    }
}

public class FeatureFlagsDemo: FeatureFlags {
    public init() {}

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

    public func setup(with context: [String: String], onComplete: @escaping (_ success: Bool) -> Void) {
        loadingExperimentsSuccess = onComplete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.loadingExperimentsSuccess(true)
        }
    }

    public func updateContext(context: [String: String]) {
    }
}

extension Dependencies {
    static public func featureFlags() -> FeatureFlags {
        let featureFlags: FeatureFlags = shared.resolve()
        return featureFlags
    }
}
