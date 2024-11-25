import Foundation

public protocol FeatureFlags {
    var isEditCoInsuredEnabled: Bool { get set }
    var isTravelInsuranceEnabled: Bool { get set }
    var isTerminationFlowEnabled: Bool { get set }
    var isUpdateNecessary: Bool { get set }
    var isChatDisabled: Bool { get set }
    var isPaymentScreenEnabled: Bool { get set }
    var isCommonClaimEnabled: Bool { get set }
    var isForeverEnabled: Bool { get set }
    var isConnectPaymentEnabled: Bool { get set }
    var isHelpCenterEnabled: Bool { get set }
    var isSubmitClaimEnabled: Bool { get set }
    func setup(with context: [String: String]) async throws
    func updateContext(context: [String: String])
    var osVersionTooLow: Bool { get set }
    var emailPreferencesEnabled: Bool { get set }
    var isTiersEnabled: Bool { get set }
    var isAddonsEnabled: Bool { get set }
    var isDemoMode: Bool { get set }
    var movingFlowVersion: MovingFlowVersion? { get set }
    var isMovingFlowEnabled: Bool { get }
}

public enum PaymentType {
    case trustly
}

public enum MovingFlowVersion: String {
    case v1
    case v2
}

extension Dependencies {
    static public func featureFlags() -> FeatureFlags {
        let featureFlags: FeatureFlags = shared.resolve()
        return featureFlags
    }
}
