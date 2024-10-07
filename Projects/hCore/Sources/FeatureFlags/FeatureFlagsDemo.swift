import Foundation

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
    public var isSubmitClaimEnabled: Bool = false
    public var osVersionTooLow: Bool = false
    public var emailPreferencesEnabled: Bool = false
    public var isTiersEnabled: Bool = false
    public var isMovingFlowWithTiersEnabled: Bool = false

    public func setup(with context: [String: String], onComplete: @escaping (_ success: Bool) -> Void) {
        loadingExperimentsSuccess = onComplete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.loadingExperimentsSuccess(true)
        }
    }

    public func updateContext(context: [String: String]) {
    }
}
