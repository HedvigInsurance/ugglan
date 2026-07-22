import Combine
import Foundation

@MainActor
public protocol FeatureFlagsClient {
    var featureData: AnyPublisher<FeatureData, Never> { get }
    func setup(with context: [String: String]) async throws
    func updateContext(context: [String: String])
}

public struct FeatureData: Codable, Equatable {
    public let isUpdateNecessary: Bool
    public let isConnectPaymentEnabled: Bool
    public let isSubmitClaimEnabled: Bool
    public let osVersionTooLow: Bool
    public let emailPreferencesEnabled: Bool
    public let isDemoMode: Bool
    public let isAddonsRemovalFromMovingFlowEnabled: Bool
    public let isNewConversationFromInboxEnabled: Bool
    public let isPuppyGuideEnabled: Bool
    public let isResumeClaimEnabled: Bool

    public init(
        isUpdateNecessary: Bool,
        isConnectPaymentEnabled: Bool,
        isSubmitClaimEnabled: Bool,
        osVersionTooLow: Bool,
        emailPreferencesEnabled: Bool,
        isDemoMode: Bool,
        isAddonsRemovalFromMovingFlowEnabled: Bool,
        isNewConversationFromInboxEnabled: Bool,
        isPuppyGuideEnabled: Bool,
        isResumeClaimEnabled: Bool
    ) {
        self.isUpdateNecessary = isUpdateNecessary
        self.isConnectPaymentEnabled = isConnectPaymentEnabled
        self.isSubmitClaimEnabled = isSubmitClaimEnabled
        self.osVersionTooLow = osVersionTooLow
        self.emailPreferencesEnabled = emailPreferencesEnabled
        self.isDemoMode = isDemoMode
        self.isAddonsRemovalFromMovingFlowEnabled = isAddonsRemovalFromMovingFlowEnabled
        self.isNewConversationFromInboxEnabled = isNewConversationFromInboxEnabled
        self.isPuppyGuideEnabled = isPuppyGuideEnabled
        self.isResumeClaimEnabled = isResumeClaimEnabled
    }
}

public enum PaymentType {
    case trustly
}

@MainActor
extension Dependencies {
    public static func featureFlags() -> FeatureFlags {
        let featureFlags: FeatureFlags = shared.resolve()
        return featureFlags
    }
}

@MainActor
@dynamicMemberLookup
public class FeatureFlags: ObservableObject {
    public static let shared = FeatureFlags()
    private var client: FeatureFlagsClient?
    private var featureDataCancellable: AnyCancellable?
    @Published public var data: FeatureData = .init(
        isUpdateNecessary: false,
        isConnectPaymentEnabled: false,
        isSubmitClaimEnabled: false,
        osVersionTooLow: false,
        emailPreferencesEnabled: false,
        isDemoMode: false,
        isAddonsRemovalFromMovingFlowEnabled: false,
        isNewConversationFromInboxEnabled: false,
        isPuppyGuideEnabled: false,
        isResumeClaimEnabled: false
    )

    public subscript<T>(dynamicMember keyPath: KeyPath<FeatureData, T>) -> T {
        data[keyPath: keyPath]
    }

    private init() {}

    public func setup(with context: [String: String]) async throws {
        let client: FeatureFlagsClient = Dependencies.shared.resolve()
        featureDataCancellable = client.featureData
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] data in
                guard let self = self else { return }
                Task {
                    log.info(
                        "Feature flag set",
                        attributes: ["featureFlags": data]
                    )
                }
                self.data = data
            }
        self.client = client
        try await client.setup(with: context)
    }

    public func updateContext(context: [String: String]) {
        client?.updateContext(context: context)
    }
}
