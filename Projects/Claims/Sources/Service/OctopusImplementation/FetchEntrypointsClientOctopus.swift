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

extension ClaimEntryPointGroupResponseModel {
    init(
        with data: OctopusGraphQL.EntrypointGroupFragment
    ) {
        self.id = data.id
        self.displayName = data.displayName
        self.entrypoints = data.entrypoints.map({ ClaimEntryPointResponseModel(with: $0.fragments.entrypointFragment) })
    }
}

extension ClaimEntryPointResponseModel {
    init(
        with data: OctopusGraphQL.EntrypointFragment

    ) {
        self.id = data.id
        self.displayName = data.displayName
        options =
            data.options?.map({ ClaimEntryPointOptionResponseModel(with: $0.fragments.entrypointOptionFragment) }) ?? []
    }
}

extension ClaimEntryPointOptionResponseModel {
    init(
        with data: OctopusGraphQL.EntrypointOptionFragment
    ) {
        self.id = data.id
        self.displayName = data.displayName
    }
}
