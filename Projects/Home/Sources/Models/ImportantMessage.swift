import Foundation

public struct ImportantMessage: Codable, Equatable, Sendable {
    let id: String
    let message: String
    let linkInfo: LinkInfo?

    struct LinkInfo: Codable, Equatable, Sendable {
        let link: URL
        let text: String
    }
}
