import Apollo
import Foundation
import authlib

class HeadersInterceptor: ApolloInterceptor {
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
    }

    func interceptAsync<Operation: GraphQLOperation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
    ) {
        var httpAdditionalHeaders = [
            "Accept-Language": acceptLanguageHeader,
            "User-Agent": userAgent,
            "hedvig-device-id": deviceIdentifier,
        ]
        
        if let token = ApolloClient.retreiveToken() {
            if Date().addingTimeInterval(60) > token.accessTokenExpirationDate {
                if Date() > token.refreshTokenExpirationDate {
                    forceLogoutHook()
                } else {
                    NetworkAuthRepository(
                        environment: Environment.current.authEnvironment
                    ).exchange(grant: RefreshTokenGrant(code: token.refreshToken)) { result, error in
                        if let successResult = result as? AuthTokenResultSuccess {
                            ApolloClient.handleAuthTokenSuccessResult(result: successResult)
                            
                            let newToken = successResult.accessToken.token
                            httpAdditionalHeaders["Authorization"] = newToken
                            
                            httpAdditionalHeaders.forEach { key, value in request.addHeader(name: key, value: value) }

                            chain.proceedAsync(
                                request: request,
                                response: response,
                                completion: completion
                            )
                        } else {
                            forceLogoutHook()
                        }
                    }
                }
            } else {
                httpAdditionalHeaders["Authorization"] = token.accessToken
                
                httpAdditionalHeaders.forEach { key, value in request.addHeader(name: key, value: value) }

                chain.proceedAsync(
                    request: request,
                    response: response,
                    completion: completion
                )
            }
        } else {
            httpAdditionalHeaders.forEach { key, value in request.addHeader(name: key, value: value) }

            chain.proceedAsync(
                request: request,
                response: response,
                completion: completion
            )
        }
    }
}
