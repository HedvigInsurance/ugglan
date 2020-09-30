import Foundation

public struct AuthorizationToken: Codable {
    public var token: String

    init(token: String) {
        self.token = token
    }
}
