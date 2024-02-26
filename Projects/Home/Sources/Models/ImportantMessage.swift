import Foundation

public struct ImportantMessage: Codable, Equatable {
    let id: String
    let message: String?
    let link: String?
}
