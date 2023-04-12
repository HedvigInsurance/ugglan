import Foundation
import hGraphQL

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
