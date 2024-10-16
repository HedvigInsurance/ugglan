import Foundation

public protocol FetchContractsClient {
    func getContracts() async throws -> ContractsStack
    func getCrossSell() async throws -> [CrossSell]
}

public struct ContractsStack {
    public let activeContracts: [Contract]
    public let pendingContracts: [Contract]
    public let terminatedContracts: [Contract]
}
