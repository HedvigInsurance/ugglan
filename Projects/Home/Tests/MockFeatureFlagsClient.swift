import Combine
import Foundation

@testable import hCore

final class MockFeatureFlagsClient: FeatureFlagsClient, @unchecked Sendable {
    private let subject = PassthroughSubject<FeatureData, Never>()

    var featureData: AnyPublisher<FeatureData, Never> {
        subject.eraseToAnyPublisher()
    }

    func setup(with _: [String: String]) async throws {}
    func updateContext(context _: [String: String]) {}

    func send(_ data: FeatureData) {
        subject.send(data)
    }
}

extension FeatureData {
    static func allOff(isNewConversationFromInboxEnabled: Bool = false) -> FeatureData {
        FeatureData(
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
            isAddonsRemovalFromMovingFlowEnabled: false,
            isClaimHistoryEnabled: false,
            isNewConversationFromInboxEnabled: isNewConversationFromInboxEnabled
        )
    }
}
