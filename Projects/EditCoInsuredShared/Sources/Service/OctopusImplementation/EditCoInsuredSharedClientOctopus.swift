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

public class EditCoInsuredSharedClientOctopus: EditCoInsuredSharedClient {
    @Inject var octopus: hOctopus
    public init() {}

    public func fetchContracts() async throws -> [Contract] {
        let query = OctopusGraphQL.ContractsQuery()
        let data = try await octopus.client.fetch(
            query: query,
            cachePolicy: .fetchIgnoringCacheCompletely
        )
        return data.currentMember.activeContracts.compactMap { activeContract in
            Contract(
                contract: activeContract.fragments.contractFragment,
                firstName: data.currentMember.firstName,
                lastName: data.currentMember.lastName,
                ssn: data.currentMember.ssn
            )
        }
    }
}
