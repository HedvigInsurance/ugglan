import Foundation

public struct AuthorizationToken: Codable {
    public var token: String

    init(token: String) { self.token = token }

    public var urlEncodedString: String? {
        let allowedCharacters = CharacterSet(charactersIn: "=").inverted

        return token.addingPercentEncoding(withAllowedCharacters: allowedCharacters)
    }
}
