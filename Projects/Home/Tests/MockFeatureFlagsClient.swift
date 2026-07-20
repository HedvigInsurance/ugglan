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
            isUpdateNecessary: false,
            isConnectPaymentEnabled: false,
            isSubmitClaimEnabled: false,
            osVersionTooLow: false,
            emailPreferencesEnabled: false,
            isDemoMode: true,
            isAddonsRemovalFromMovingFlowEnabled: false,
            isNewConversationFromInboxEnabled: isNewConversationFromInboxEnabled,
            isPuppyGuideEnabled: false
        )
    }
}
