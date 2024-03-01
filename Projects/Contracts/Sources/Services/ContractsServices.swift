import Foundation

public protocol FetchContractsService {
    func getContracts() async throws -> ContractsStack
    func getCrossSell() async throws -> [CrossSell]
}

public struct ContractsStack {
    public let activeContracts: [Contract]
    public let pendingContracts: [Contract]
    public let termiantedContracts: [Contract]
}
