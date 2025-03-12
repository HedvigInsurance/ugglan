import SwiftUI
import hGraphQL

public struct ClaimEntryPointGroupResponseModel: Codable, Equatable, Hashable, Sendable {
    let id: String
    let displayName: String
    var entrypoints: [ClaimEntryPointResponseModel]

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

public struct ClaimEntryPointResponseModel: Codable, Equatable, Hashable, Sendable {
    let id: String
    let displayName: String
    var options: [ClaimEntryPointOptionResponseModel]

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

public struct ClaimEntryPointOptionResponseModel: Codable, Equatable, Hashable, Sendable {
    let id: String
    let displayName: String

    init(
        id: String,
        displayName: String
    ) {
        self.id = id
        self.displayName = displayName
    }
}
