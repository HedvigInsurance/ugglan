import Foundation

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
    var isSubmitClaimEnabled: Bool { get set }
    func setup(with context: [String: String], onComplete: @escaping (_ success: Bool) -> Void)
    func updateContext(context: [String: String])
    var osVersionTooLow: Bool { get set }
    var emailPreferencesEnabled: Bool { get set }
}

public enum PaymentType {
    case trustly
    case adyen
}

extension Dependencies {
    static public func featureFlags() -> FeatureFlags {
        let featureFlags: FeatureFlags = shared.resolve()
        return featureFlags
    }
}
