import Foundation

public protocol FetchContractsService {
    func getContracts() async throws -> ContractsStack
}

public struct ContractsStack {
    public let activeContracts: [Contract]
    public let pendingContracts: [Contract]
    public let termiantedContracts: [Contract]
}
