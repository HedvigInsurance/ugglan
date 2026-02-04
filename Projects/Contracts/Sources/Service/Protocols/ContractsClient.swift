import Addons
import Foundation

@MainActor
public protocol FetchContractsClient {
    func getContracts() async throws -> ContractsStack
    func getAddonBanners(source: AddonSource) async throws -> [AddonBannerModel]
}

public struct ContractsStack: Sendable {
    public let activeContracts: [Contract]
    public let pendingContracts: [Contract]
    public let terminatedContracts: [Contract]

    public init(activeContracts: [Contract], pendingContracts: [Contract], terminatedContracts: [Contract]) {
        self.activeContracts = activeContracts
        self.pendingContracts = pendingContracts
        self.terminatedContracts = terminatedContracts
    }
}
