@MainActor
public protocol AuthorizationCodeClient: Sendable {
    func getAuthorizationCode() async throws -> AuthorizationCodeCreationOutput
}

public struct AuthorizationCodeCreationOutput: Codable, Sendable {
    public let authorizationCode: String

    public init(authorizationCode: String) {
        self.authorizationCode = authorizationCode
    }
}
