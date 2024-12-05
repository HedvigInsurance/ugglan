import Addons
import Foundation

@MainActor
public protocol FetchContractsClient {
    func getContracts() async throws -> ContractsStack
    func getCrossSell() async throws -> [CrossSell]
    func getAddonBannerModel() async throws -> AddonBannerModel?
}

public struct ContractsStack: Sendable {
    public let activeContracts: [Contract]
    public let pendingContracts: [Contract]
    public let terminatedContracts: [Contract]
}
