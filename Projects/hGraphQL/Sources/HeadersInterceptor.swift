import Apollo
import Foundation

public enum AuthError: Error {
    case refreshTokenExpired
    case refreshFailed
    case networkIssue
}

class HeadersInterceptor: @preconcurrency ApolloInterceptor {
    var id: String
    let headers: [String: String]
    init(
        headers: [String: String] = [:],
    ) {
        self.headers = headers
        id = UUID().uuidString
    }

    @MainActor
    func interceptAsync<Operation: GraphQLOperation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
    ) {
        Task {
            do {
                try await TokenRefresher.shared.refreshIfNeeded()

                headers.forEach { key, value in request.addHeader(name: key, value: value) }
                let token = try await ApolloClient.retreiveToken()
                if let token = token {
                    request.addHeader(name: "Authorization", value: "Bearer " + token.accessToken)
                }
                chain.proceedAsync(
                    request: request,
                    response: response,
                    interceptor: self,
                    completion: completion
                )
            } catch {
                chain.handleErrorAsync(
                    error,
                    request: request,
                    response: response,
                    completion: completion
                )
            }
        }
    }
}
