import SubmitClaim
import hCore
import hGraphQL

class FetchEntrypointsClientOctopus: hFetchEntrypointsClient {
    @Inject private var octopus: hOctopus

    func get() async throws -> [ClaimEntryPointGroupResponseModel] {
        let data = try await octopus.client.fetchQuery(
            query: OctopusGraphQL.EntrypointGroupsQuery(type: GraphQLEnum<OctopusGraphQL.EntrypointType>(.claim))
        )
        let entrypointModel = data.entrypointGroups.map { data in
            ClaimEntryPointGroupResponseModel(with: data.fragments.entrypointGroupFragment)
        }
        return entrypointModel
    }
}

extension ClaimEntryPointGroupResponseModel {
    fileprivate init(
        with data: OctopusGraphQL.EntrypointGroupFragment
    ) {
        self.init(
            id: data.id,
            displayName: data.displayName,
            entrypoints: data.entrypoints.map { ClaimEntryPointResponseModel(with: $0.fragments.entrypointFragment) }
        )
    }
}

extension ClaimEntryPointResponseModel {
    fileprivate init(
        with data: OctopusGraphQL.EntrypointFragment

    ) {
        self.init(
            id: data.id,
            displayName: data.displayName,
            options: data.options?
                .map { ClaimEntryPointOptionResponseModel(with: $0.fragments.entrypointOptionFragment) } ?? []
        )
    }
}

extension ClaimEntryPointOptionResponseModel {
    fileprivate init(
        with data: OctopusGraphQL.EntrypointOptionFragment
    ) {
        self.init(
            id: data.id,
            displayName: data.displayName
        )
    }
}
