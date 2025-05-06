import Foundation
import hCore

@MainActor
public protocol EditCoInsuredSharedClient {
    func fetchContracts() async throws -> [Contract]
}
