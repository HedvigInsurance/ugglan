import Foundation

public class FeatureFlagsDemo: FeatureFlags {
    public init() {}

    public var isDemoMode: Bool = true
    public var isEditCoInsuredEnabled: Bool = false
    public var isTravelInsuranceEnabled: Bool = false
    public var isTerminationFlowEnabled: Bool = false
    public var isUpdateNecessary: Bool = false
    public var isChatDisabled: Bool = false
    public var isPaymentScreenEnabled: Bool = false
    public var isCommonClaimEnabled: Bool = false
    public var isForeverEnabled: Bool = false
    public var isConnectPaymentEnabled: Bool = false
    public var isHelpCenterEnabled: Bool = false
    public var isSubmitClaimEnabled: Bool = false
    public var osVersionTooLow: Bool = false
    public var emailPreferencesEnabled: Bool = false
    public var isAddonsEnabled: Bool = false
    public var isMovingFlowEnabled: Bool = false

    public func setup(with context: [String: String]) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
    }

    public func updateContext(context: [String: String]) {
    }
}
