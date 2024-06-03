import Foundation
import hCore
import hGraphQL

public class FetchEntrypointsClientOctopus: hFetchEntrypointsClient {
    @Inject var octopus: hOctopus

    public init() {}

    public func get() async throws -> [ClaimEntryPointGroupResponseModel] {
        let data = try await octopus.client.fetch(
            query: OctopusGraphQL.EntrypointGroupsQuery(type: GraphQLEnum<OctopusGraphQL.EntrypointType>(.claim)),
            cachePolicy: .fetchIgnoringCacheCompletely
        )
        let entrypointModel = data.entrypointGroups.map { data in
            ClaimEntryPointGroupResponseModel(with: data.fragments.entrypointGroupFragment)
        }
        return entrypointModel
    }
}
