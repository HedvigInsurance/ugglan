import EditCoInsuredShared
import Foundation
import hCore
import hGraphQL

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
