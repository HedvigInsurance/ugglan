import Combine
import Foundation

public class FeatureFlagsDemo: @unchecked Sendable, FeatureFlagsClient {

    public init() {}
    private let featureDataPublisher = PassthroughSubject<FeatureData, Never>()

    public var featureData: AnyPublisher<FeatureData, Never> {
        return featureDataPublisher.eraseToAnyPublisher()
    }

    public func setup(with context: [String: String]) async throws {
        let data = FeatureData(
            isTerminationFlowEnabled: false,
            isUpdateNecessary: false,
            isChatDisabled: false,
            isPaymentScreenEnabled: false,
            isConnectPaymentEnabled: false,
            isHelpCenterEnabled: false,
            isSubmitClaimEnabled: false,
            osVersionTooLow: false,
            emailPreferencesEnabled: false,
            isDemoMode: true,
            isMovingFlowEnabled: false,
            isAddonsRemovalFromMovingFlowEnabled: false
        )
        featureDataPublisher.send(data)
    }
    public func updateContext(context: [String: String]) {
        let data = FeatureData(
            isTerminationFlowEnabled: false,
            isUpdateNecessary: false,
            isChatDisabled: false,
            isPaymentScreenEnabled: false,
            isConnectPaymentEnabled: false,
            isHelpCenterEnabled: false,
            isSubmitClaimEnabled: false,
            osVersionTooLow: false,
            emailPreferencesEnabled: false,
            isDemoMode: true,
            isMovingFlowEnabled: false,
            isAddonsRemovalFromMovingFlowEnabled: false
        )
        featureDataPublisher.send(data)

    }
}
