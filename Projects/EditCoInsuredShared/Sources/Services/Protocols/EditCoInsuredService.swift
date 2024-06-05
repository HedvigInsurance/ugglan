import Foundation
import hCore
import hGraphQL

public protocol EditCoInsuredSharedService {
    func fetchContracts() async throws -> [Contract]
}
