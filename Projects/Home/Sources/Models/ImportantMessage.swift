import Foundation

public struct ImportantMessage: Codable, Equatable {
    let id: String
    let message: String
    let linkInfo: LinkInfo?

    struct LinkInfo: Codable, Equatable {
        let link: URL
        let text: String
    }
}
