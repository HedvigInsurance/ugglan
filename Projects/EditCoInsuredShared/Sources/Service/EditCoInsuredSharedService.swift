import Foundation
import hCore
import hGraphQL

@MainActor
public class EditCoInsuredSharedService {
    @Inject var service: EditCoInsuredSharedClient

    public func fetchContracts() async throws -> [Contract] {
        log.info("EditCoInsuredSharedService: fetchContracts", error: nil, attributes: nil)
        return try await service.fetchContracts()
    }
}
