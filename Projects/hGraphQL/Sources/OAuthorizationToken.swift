import AutomaticLog
import Foundation

@Loggable
public struct OAuthorizationToken: Codable {
    @Sensitive public var accessToken: String
    public var accessTokenExpirationDate: Date
    @Sensitive public var refreshToken: String
    public var refreshTokenExpirationDate: Date

    public init(
        accessToken: String,
        accessTokenExpirationDate: Date,
        refreshToken: String,
        refreshTokenExpirationDate: Date
    ) {
        self.accessToken = accessToken
        self.accessTokenExpirationDate = accessTokenExpirationDate
        self.refreshToken = refreshToken
        self.refreshTokenExpirationDate = refreshTokenExpirationDate
    }
}

extension OAuthorizationToken: Sendable {}
