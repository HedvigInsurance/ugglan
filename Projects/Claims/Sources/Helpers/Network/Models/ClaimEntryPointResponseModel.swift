import Foundation
import hCoreUI
import hGraphQL

public struct ClaimEntryPointGroupResponseModel: Codable, Equatable, Hashable {
    let id: String
    let displayName: String
    let icon: Icon

    init(
        id: String,
        displayName: String,
        icon: Icon
    ) {
        self.id = id
        self.displayName = displayName
        self.icon = icon
    }
}

enum Icon: Codable, Equatable, Hashable {
    case home
    case accident
    case car
    case travel
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
