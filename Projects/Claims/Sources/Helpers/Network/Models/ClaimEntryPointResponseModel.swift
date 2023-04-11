import Foundation
import hGraphQL

public struct ClaimEntryPointResponseModel: Codable, Equatable {
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
