import Combine
import Foundation

@MainActor
public protocol FeatureFlagsClient {
    var featureData: AnyPublisher<FeatureData, Never> { get }
    func setup(with context: [String: String]) async throws
    func updateContext(context: [String: String])
}

public struct FeatureData: Codable, Equatable {
    public let isTerminationFlowEnabled: Bool
    public let isUpdateNecessary: Bool
    public let isPaymentScreenEnabled: Bool
    public let isConnectPaymentEnabled: Bool
    public let isHelpCenterEnabled: Bool
    public let isSubmitClaimEnabled: Bool
    public let osVersionTooLow: Bool
    public let emailPreferencesEnabled: Bool
    public let isDemoMode: Bool
    public let isMovingFlowEnabled: Bool
    public let isAddonsRemovalFromMovingFlowEnabled: Bool
    public let isClaimHistoryEnabled: Bool

    public init(
        isTerminationFlowEnabled: Bool,
        isUpdateNecessary: Bool,
        isPaymentScreenEnabled: Bool,
        isConnectPaymentEnabled: Bool,
        isHelpCenterEnabled: Bool,
        isSubmitClaimEnabled: Bool,
        osVersionTooLow: Bool,
        emailPreferencesEnabled: Bool,
        isDemoMode: Bool,
        isMovingFlowEnabled: Bool,
        isAddonsRemovalFromMovingFlowEnabled: Bool,
        isClaimHistoryEnabled: Bool
    ) {
        self.isTerminationFlowEnabled = isTerminationFlowEnabled
        self.isUpdateNecessary = isUpdateNecessary
        self.isPaymentScreenEnabled = isPaymentScreenEnabled
        self.isConnectPaymentEnabled = isConnectPaymentEnabled
        self.isHelpCenterEnabled = isHelpCenterEnabled
        self.isSubmitClaimEnabled = isSubmitClaimEnabled
        self.osVersionTooLow = osVersionTooLow
        self.emailPreferencesEnabled = emailPreferencesEnabled
        self.isDemoMode = isDemoMode
        self.isMovingFlowEnabled = isMovingFlowEnabled
        self.isAddonsRemovalFromMovingFlowEnabled = isAddonsRemovalFromMovingFlowEnabled
        self.isClaimHistoryEnabled = isClaimHistoryEnabled
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
    @Published private var data: FeatureData = .init(
        isTerminationFlowEnabled: false,
        isUpdateNecessary: false,
        isPaymentScreenEnabled: false,
        isConnectPaymentEnabled: false,
        isHelpCenterEnabled: false,
        isSubmitClaimEnabled: false,
        osVersionTooLow: false,
        emailPreferencesEnabled: false,
        isDemoMode: false,
        isMovingFlowEnabled: false,
        isAddonsRemovalFromMovingFlowEnabled: false,
        isClaimHistoryEnabled: false
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
