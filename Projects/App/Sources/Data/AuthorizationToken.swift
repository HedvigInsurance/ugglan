import Foundation

struct AuthorizationToken: Codable {
    var token: String

    init(token: String) {
        self.token = token
    }
}
