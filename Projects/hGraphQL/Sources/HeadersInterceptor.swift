import Apollo
import Foundation
import authlib

enum AuthError: Error {
    case refreshTokenExpired
    case refreshFailed
}

class HeadersInterceptor: ApolloInterceptor {
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
        self.id = UUID().uuidString
    }

    func interceptAsync<Operation: GraphQLOperation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
    ) {
        var httpAdditionalHeaders = [
            "Accept-Language": acceptLanguageHeader,
            "hedvig-language": acceptLanguageHeader,
            "User-Agent": userAgent,
            "hedvig-device-id": deviceIdentifier,
            "Hedvig-TimeZone": TimeZone.current.identifier,
        ]

        TokenRefresher.shared.refreshIfNeeded()
            .onValue {
                if let token = ApolloClient.retreiveToken() {
                    httpAdditionalHeaders["Authorization"] = "Bearer " + token.accessToken
                }

                httpAdditionalHeaders.forEach { key, value in request.addHeader(name: key, value: value) }

                chain.proceedAsync(
                    request: request,
                    response: response,
                    completion: completion
                )
            }
            .onError { error in
                chain.handleErrorAsync(
                    error,
                    request: request,
                    response: response,
                    completion: completion
                )
            }
    }
}
