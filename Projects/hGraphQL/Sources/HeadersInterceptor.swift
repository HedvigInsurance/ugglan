import Apollo
import Foundation

public enum AuthError: Error {
    case refreshTokenExpired
    case refreshFailed
    case networkIssue
}

class HeadersInterceptor: @preconcurrency ApolloInterceptor {
    var id: String
    let acceptLanguageHeader: String
    let userAgent: String
    let deviceIdentifier: String
    init(
        acceptLanguageHeader: String,
        userAgent: String,
        deviceIdentifier: String
    ) {
        self.acceptLanguageHeader = acceptLanguageHeader
        self.userAgent = userAgent
        self.deviceIdentifier = deviceIdentifier
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
                var httpAdditionalHeaders = [
                    "Accept-Language": acceptLanguageHeader,
                    "hedvig-language": acceptLanguageHeader,
                    "User-Agent": userAgent,
                    "hedvig-device-id": deviceIdentifier,
                    "Hedvig-TimeZone": TimeZone.current.identifier,
                ]
                let token = try await ApolloClient.retreiveToken()
                if let token = token {
                    httpAdditionalHeaders["Authorization"] = "Bearer " + token.accessToken
                }

                httpAdditionalHeaders.forEach { key, value in request.addHeader(name: key, value: value) }
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
