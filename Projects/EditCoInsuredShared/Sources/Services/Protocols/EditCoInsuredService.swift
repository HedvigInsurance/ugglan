import Foundation
import hCore
import hGraphQL

public protocol EditCoInsuredSharedClient {
    func fetchContracts() async throws -> [Contract]
}
