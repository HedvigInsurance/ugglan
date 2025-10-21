import Apollo
import Foundation

public enum AuthError: Error {
    case refreshTokenExpired
    case refreshFailed
    case networkIssue
}

struct HeadersInterceptor: HTTPInterceptor {
    let headers: [String: String]
    init(
        headers: [String: String] = [:],
    ) {
        self.headers = headers
    }

    func intercept(request: URLRequest, next: (URLRequest) async throws -> HTTPResponse) async throws -> HTTPResponse {
        try await TokenRefresher.shared.refreshIfNeeded()
        var newRequest = request
        headers.forEach { key, value in newRequest.setValue(value, forHTTPHeaderField: key) }
        let token = try await ApolloClient.retreiveToken()
        if let token = token {
            newRequest.setValue("Bearer " + token.accessToken, forHTTPHeaderField: "Authorization")
        }
        return try await next(newRequest)
    }
}
