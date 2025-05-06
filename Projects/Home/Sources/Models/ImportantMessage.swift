import Foundation

public struct ImportantMessage: Codable, Equatable, Sendable {
    let id: String
    let message: String
    let linkInfo: LinkInfo?

    public init(id: String, message: String, linkInfo: LinkInfo?) {
        self.id = id
        self.message = message
        self.linkInfo = linkInfo
    }

    public struct LinkInfo: Codable, Equatable, Sendable {
        let link: URL
        let text: String

        public init(link: URL, text: String) {
            self.link = link
            self.text = text
        }
    }
}
