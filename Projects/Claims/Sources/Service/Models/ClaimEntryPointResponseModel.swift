import SwiftUI
import hGraphQL

public struct ClaimEntryPointGroupResponseModel: Codable, Equatable, Hashable {
    let id: String
    let displayName: String
    var entrypoints: [ClaimEntryPointResponseModel]

    init(
        with data: OctopusGraphQL.EntrypointGroupFragment
    ) {
        self.id = data.id
        self.displayName = data.displayName
        self.entrypoints = data.entrypoints.map({ ClaimEntryPointResponseModel(with: $0.fragments.entrypointFragment) })
    }

    init(
        id: String,
        displayName: String,
        entrypoints: [ClaimEntryPointResponseModel]
    ) {
        self.id = id
        self.displayName = displayName
        self.entrypoints = entrypoints
    }

}

public struct ClaimEntryPointResponseModel: Codable, Equatable, Hashable {
    let id: String
    let displayName: String
    var options: [ClaimEntryPointOptionResponseModel]

    init(
        with data: OctopusGraphQL.EntrypointFragment

    ) {
        self.id = data.id
        self.displayName = data.displayName
        options =
            data.options?.map({ ClaimEntryPointOptionResponseModel(with: $0.fragments.entrypointOptionFragment) }) ?? []
    }

    init(
        id: String,
        displayName: String,
        options: [ClaimEntryPointOptionResponseModel]
    ) {
        self.id = id
        self.displayName = displayName
        self.options = options
    }
}

public struct ClaimEntryPointOptionResponseModel: Codable, Equatable, Hashable {
    let id: String
    let displayName: String

    init(
        with data: OctopusGraphQL.EntrypointOptionFragment
    ) {
        self.id = data.id
        self.displayName = data.displayName
    }

    init(
        id: String,
        displayName: String
    ) {
        self.id = id
        self.displayName = displayName
    }
}
