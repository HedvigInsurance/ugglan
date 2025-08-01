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
    public let isChatDisabled: Bool
    public let isPaymentScreenEnabled: Bool
    public let isConnectPaymentEnabled: Bool
    public let isHelpCenterEnabled: Bool
    public let isSubmitClaimEnabled: Bool
    public let osVersionTooLow: Bool
    public let emailPreferencesEnabled: Bool
    public let isDemoMode: Bool
    public let isMovingFlowEnabled: Bool
    public let isAddonsRemovalFromMovingFlowEnabled: Bool

    public init(
        isTerminationFlowEnabled: Bool,
        isUpdateNecessary: Bool,
        isChatDisabled: Bool,
        isPaymentScreenEnabled: Bool,
        isConnectPaymentEnabled: Bool,
        isHelpCenterEnabled: Bool,
        isSubmitClaimEnabled: Bool,
        osVersionTooLow: Bool,
        emailPreferencesEnabled: Bool,
        isDemoMode: Bool,
        isMovingFlowEnabled: Bool,
        isAddonsRemovalFromMovingFlowEnabled: Bool
    ) {
        self.isTerminationFlowEnabled = isTerminationFlowEnabled
        self.isUpdateNecessary = isUpdateNecessary
        self.isChatDisabled = isChatDisabled
        self.isPaymentScreenEnabled = isPaymentScreenEnabled
        self.isConnectPaymentEnabled = isConnectPaymentEnabled
        self.isHelpCenterEnabled = isHelpCenterEnabled
        self.isSubmitClaimEnabled = isSubmitClaimEnabled
        self.osVersionTooLow = osVersionTooLow
        self.emailPreferencesEnabled = emailPreferencesEnabled
        self.isDemoMode = isDemoMode
        self.isMovingFlowEnabled = isMovingFlowEnabled
        self.isAddonsRemovalFromMovingFlowEnabled = isAddonsRemovalFromMovingFlowEnabled
    }
}

public enum PaymentType {
    case trustly
}

@MainActor
public extension Dependencies {
    static func featureFlags() -> FeatureFlags {
        let featureFlags: FeatureFlags = shared.resolve()
        return featureFlags
    }
}

@MainActor
public class FeatureFlags: ObservableObject {
    public static let shared = FeatureFlags()
    private var client: FeatureFlagsClient?
    private var featureDataCancellable: AnyCancellable?
    @Published public private(set) var isTerminationFlowEnabled = false // need rework
    @Published public private(set) var isUpdateNecessary = false
    @Published public private(set) var isChatDisabled = false // need to reintroduce
    @Published public private(set) var isPaymentScreenEnabled = false
    @Published public private(set) var isConnectPaymentEnabled = false
    @Published public private(set) var isHelpCenterEnabled = false
    @Published public private(set) var isSubmitClaimEnabled = false
    @Published public private(set) var osVersionTooLow = false
    @Published public private(set) var emailPreferencesEnabled = false
    @Published public private(set) var isDemoMode = false
    @Published public private(set) var isMovingFlowEnabled = false
    @Published public private(set) var isAddonsRemovalFromMovingFlowEnabled = false

    private init() {}

    public func setup(with context: [String: String]) async throws {
        let client: FeatureFlagsClient = Dependencies.shared.resolve()
        featureDataCancellable = client.featureData
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .sink { data in
                Task {
                    log.info(
                        "Feature flag set",
                        attributes: ["featureFlags": data]
                    )
                }
                self.isTerminationFlowEnabled = data.isTerminationFlowEnabled
                self.isUpdateNecessary = data.isUpdateNecessary
                self.isChatDisabled = data.isChatDisabled
                self.isPaymentScreenEnabled = data.isPaymentScreenEnabled
                self.isConnectPaymentEnabled = data.isConnectPaymentEnabled
                self.isHelpCenterEnabled = data.isHelpCenterEnabled
                self.isSubmitClaimEnabled = data.isSubmitClaimEnabled
                self.osVersionTooLow = data.osVersionTooLow
                self.emailPreferencesEnabled = data.emailPreferencesEnabled
                self.isDemoMode = data.isDemoMode
                self.isMovingFlowEnabled = data.isMovingFlowEnabled
                self.isAddonsRemovalFromMovingFlowEnabled = data.isAddonsRemovalFromMovingFlowEnabled
            }
        self.client = client
        try await client.setup(with: context)
    }

    public func updateContext(context: [String: String]) {
        client?.updateContext(context: context)
    }
}
