import Foundation
import UnleashProxyClientSwift
import hGraphQL

public class FeatureFlags {
    public static let shared = FeatureFlags()
    private var unleashClient: UnleashClient?
    public init() {}

    private var loadingExperimentsSuccess: (Bool) -> Void = { _ in }
    @Published public var isMovingFlowEnabled = false
    @Published public var isEditCoInsuredEnabled = false
    @Published public var isTravelInsuranceEnabled = false
    @Published public var isTerminationFlowEnabled = false
    @Published public var isUpdateNecessary = false
    @Published public var isChatDisabled = false
    @Published public var isPaymentScreenEnabled = false
    @Published public var isHedvigLettersFontEnabled = false
    @Published public var isCommonClaimEnabled = false
    @Published public var isForeverEnabled = false
    @Published public var paymentType: PaymentType = .trustly

    public enum PaymentType {
        case trustly
        case adyen
    }

    public func setup(with context: [String: String], onComplete: @escaping (_ success: Bool) -> Void) {
        var clientKey: String {
            switch Environment.current {
            case .production:
                return "*:production.21d6af57ae16320fde3a3caf024162db19cc33bf600ab7439c865c20"
            case .custom, .staging:
                return "*:development.f2455340ac9d599b5816fa879d079f21dd0eb03e4315130deb5377b6"
            }
        }

        let environment = clientKey.replacingOccurrences(of: "*:", with: "").components(separatedBy: ".")[0]

        unleashClient = UnleashProxyClientSwift.UnleashClient(
            unleashUrl: "https://eu.app.unleash-hosted.com/eubb1047/api/frontend",
            clientKey: clientKey,
            refreshInterval: 15,
            appName: "ios",
            environment: environment,
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

        print("feature flag ", movingFlowKey, " ", isMovingFlowEnabled)

        let editCoInsuredKey = "edit_coinsured"
        isEditCoInsuredEnabled = unleashClient.isEnabled(name: editCoInsuredKey)

        log.info(
            "feature flag info",
            attributes: [
                "flag": editCoInsuredKey,
                "enabled": isEditCoInsuredEnabled,
            ]
        )

        print("feature flag ", editCoInsuredKey, " ", isEditCoInsuredEnabled)

        let travelInsuranceKey = "travel_insurance"
        isTravelInsuranceEnabled = unleashClient.isEnabled(name: travelInsuranceKey)
        log.info(
            "feature flag info",
            attributes: [
                "flag": travelInsuranceKey,
                "enabled": isTravelInsuranceEnabled,
            ]
        )

        print("feature flag ", travelInsuranceKey, " ", isTravelInsuranceEnabled)

        let terminationFlowKey = "termination_flow"
        isTerminationFlowEnabled = unleashClient.isEnabled(name: terminationFlowKey)
        log.info(
            "feature flag info",
            attributes: [
                "flag": terminationFlowKey,
                "enabled": isTerminationFlowEnabled,
            ]
        )

        print("feature flag ", terminationFlowKey, " ", isTerminationFlowEnabled)

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

        let hedvigLettersFontKey = "use_hedvig_letters_font"
        isHedvigLettersFontEnabled = unleashClient.isEnabled(name: hedvigLettersFontKey)
        log.info(
            "feature flag info",
            attributes: [
                "flag": hedvigLettersFontKey,
                "enabled": isHedvigLettersFontEnabled,
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

extension Dictionary {
    public static func == (lhs: [String: AnyObject], rhs: [String: AnyObject]) -> Bool {
        return NSDictionary(dictionary: lhs).isEqual(to: rhs)
    }
}
