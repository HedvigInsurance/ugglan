import Foundation

public struct AuthorizationTokenDto {
    let accessToken: String
    let accessTokenExpiryIn: Int
    let refreshToken: String
    let refreshTokenExpiryIn: Int

    public init(accessToken: String, accessTokenExpiryIn: Int, refreshToken: String, refreshTokenExpiryIn: Int) {
        self.accessToken = accessToken
        self.accessTokenExpiryIn = accessTokenExpiryIn
        self.refreshToken = refreshToken
        self.refreshTokenExpiryIn = refreshTokenExpiryIn
    }
}
