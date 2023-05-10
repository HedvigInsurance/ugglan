import Foundation
import hCoreUI
import hGraphQL

public struct ClaimEntryPointGroupResponseModel: Codable, Equatable, Hashable {
    let id: String
    let displayName: String
    let icon: String

    init(
        id: String,
        displayName: String,
        icon: String
    ) {
        self.id = id
        self.displayName = displayName
        self.icon = icon
    }
}

public struct ClaimEntryPointResponseModel: Codable, Equatable, Hashable {
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
