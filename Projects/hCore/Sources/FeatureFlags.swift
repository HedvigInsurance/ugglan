import Foundation
import UnleashProxyClientSwift
import hGraphQL

public class FeatureFlags {
    public static let shared = FeatureFlags()
    private var unleashClient: UnleashClient?
    public init() {}

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

    public func setup(with context: [String: String]) {
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
                    log.info("Failed loading unleash experiments")
                }
            )
    }

    private func handleReady() {
        setFeatureFlags()
        log.info("Successfully loaded unleash experiments")
    }

    private func handleUpdate() {
        setFeatureFlags()
    }

    private func setFeatureFlags() {
        guard let unleashClient else {
            return
        }
        isMovingFlowEnabled = unleashClient.isEnabled(name: "moving_flow")
        isEditCoInsuredEnabled = unleashClient.isEnabled(name: "edit_coinsured")
        isTravelInsuranceEnabled = unleashClient.isEnabled(name: "travel_insurance")
        isTerminationFlowEnabled = unleashClient.isEnabled(name: "termination_flow")
        isUpdateNecessary = unleashClient.isEnabled(name: "update_necessary")
        isChatDisabled = unleashClient.isEnabled(name: "disable_chat")
        isPaymentScreenEnabled = unleashClient.isEnabled(name: "payment_screen")
        isHedvigLettersFontEnabled = unleashClient.isEnabled(name: "use_hedvig_letters_font")

        let paymentTypeName = unleashClient.getVariant(name: "payment_type").name
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
