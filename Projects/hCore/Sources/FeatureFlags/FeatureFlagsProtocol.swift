import Combine
import Foundation

@MainActor
public protocol FeatureFlagsClient {
    var featureData: AnyPublisher<FeatureData, Never> { get }
    func setup(with context: [String: String]) async throws
    func updateContext(context: [String: String])
}

public struct FeatureData: Codable, Equatable {
    public let isEditCoInsuredEnabled: Bool
    public let isTravelInsuranceEnabled: Bool
    public let isTerminationFlowEnabled: Bool
    public let isUpdateNecessary: Bool
    public let isChatDisabled: Bool
    public let isPaymentScreenEnabled: Bool
    public let isConnectPaymentEnabled: Bool
    public let isHelpCenterEnabled: Bool
    public let isSubmitClaimEnabled: Bool
    public let osVersionTooLow: Bool
    public let emailPreferencesEnabled: Bool
    public let isAddonsEnabled: Bool
    public let isDemoMode: Bool
    public let isMovingFlowEnabled: Bool
    public let isAddonsRemovalFromMovingFlowEnabled: Bool

    public init(
        isEditCoInsuredEnabled: Bool,
        isTravelInsuranceEnabled: Bool,
        isTerminationFlowEnabled: Bool,
        isUpdateNecessary: Bool,
        isChatDisabled: Bool,
        isPaymentScreenEnabled: Bool,
        isConnectPaymentEnabled: Bool,
        isHelpCenterEnabled: Bool,
        isSubmitClaimEnabled: Bool,
        osVersionTooLow: Bool,
        emailPreferencesEnabled: Bool,
        isAddonsEnabled: Bool,
        isDemoMode: Bool,
        isMovingFlowEnabled: Bool,
        isAddonsRemovalFromMovingFlowEnabled: Bool
    ) {
        self.isEditCoInsuredEnabled = isEditCoInsuredEnabled
        self.isTravelInsuranceEnabled = isTravelInsuranceEnabled
        self.isTerminationFlowEnabled = isTerminationFlowEnabled
        self.isUpdateNecessary = isUpdateNecessary
        self.isChatDisabled = isChatDisabled
        self.isPaymentScreenEnabled = isPaymentScreenEnabled
        self.isConnectPaymentEnabled = isConnectPaymentEnabled
        self.isHelpCenterEnabled = isHelpCenterEnabled
        self.isSubmitClaimEnabled = isSubmitClaimEnabled
        self.osVersionTooLow = osVersionTooLow
        self.emailPreferencesEnabled = emailPreferencesEnabled
        self.isAddonsEnabled = isAddonsEnabled
        self.isDemoMode = isDemoMode
        self.isMovingFlowEnabled = isMovingFlowEnabled
        self.isAddonsRemovalFromMovingFlowEnabled = isAddonsRemovalFromMovingFlowEnabled
    }
}

public enum PaymentType {
    case trustly
}

@MainActor
extension Dependencies {
    static public func featureFlags() -> FeatureFlags {
        let featureFlags: FeatureFlags = shared.resolve()
        return featureFlags
    }
}

@MainActor
public class FeatureFlags: ObservableObject {
    public static let shared = FeatureFlags()
    private var client: FeatureFlagsClient?
    private var featureDataCancellable: AnyCancellable?
    @Published public private(set) var isEditCoInsuredEnabled = false
    @Published public private(set) var isTravelInsuranceEnabled = false
    @Published public private(set) var isTerminationFlowEnabled = false
    @Published public private(set) var isUpdateNecessary = false  //migrated
    @Published public private(set) var isChatDisabled = false
    @Published public private(set) var isPaymentScreenEnabled = false  //migrated
    @Published public private(set) var isConnectPaymentEnabled = false  //no need
    @Published public private(set) var isHelpCenterEnabled = false  //migrated
    @Published public private(set) var isSubmitClaimEnabled = false  //migrated
    @Published public private(set) var osVersionTooLow = false  //migrated
    @Published public private(set) var emailPreferencesEnabled = false  //migrated
    @Published public private(set) var isAddonsEnabled = false
    @Published public private(set) var isDemoMode = false
    @Published public private(set) var isMovingFlowEnabled = false
    @Published public private(set) var isAddonsRemovalFromMovingFlowEnabled = false

    private init() {
    }

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
                self.isEditCoInsuredEnabled = data.isEditCoInsuredEnabled
                self.isTravelInsuranceEnabled = data.isTravelInsuranceEnabled
                self.isTerminationFlowEnabled = data.isTerminationFlowEnabled
                self.isUpdateNecessary = data.isUpdateNecessary
                self.isChatDisabled = data.isChatDisabled
                self.isPaymentScreenEnabled = data.isPaymentScreenEnabled
                self.isConnectPaymentEnabled = data.isConnectPaymentEnabled
                self.isHelpCenterEnabled = data.isHelpCenterEnabled
                self.isSubmitClaimEnabled = data.isSubmitClaimEnabled
                self.osVersionTooLow = data.osVersionTooLow
                self.emailPreferencesEnabled = data.emailPreferencesEnabled
                self.isAddonsEnabled = data.isAddonsEnabled
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
