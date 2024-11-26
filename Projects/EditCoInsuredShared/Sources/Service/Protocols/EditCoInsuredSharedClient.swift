import Foundation
import hCore
import hGraphQL

@MainActor
public protocol EditCoInsuredSharedClient {
    func fetchContracts() async throws -> [Contract]
}
