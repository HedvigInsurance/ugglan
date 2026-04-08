import Apollo
import Authentication
import Environment
import Foundation
import hCore
import hGraphQL

extension NetworkClient: @retroactive AuthorizationCodeClient {
    public func getAuthorizationCode() async throws -> AuthorizationCodeCreationOutput {
        let request = try await AuthorizationCodeRequest.createCode.asRequest()
        let response: AuthorizationCodeCreationOutput = try await withCheckedThrowingContinuation { continuation in
            let task = self.sessionClient.dataTask(with: request) { [weak self] data, response, error in
                Task {
                    do {
                        guard let self else {
                            continuation.resume(
                                throwing: NSError(
                                    domain: "NetworkClient",
                                    code: -1,
                                    userInfo: [NSLocalizedDescriptionKey: "NetworkClient was deallocated"]
                                )
                            )
                            return
                        }
                        let result: AuthorizationCodeCreationOutput = try await self.handleResponseForced(
                            data: data,
                            response: response,
                            error: error
                        )
                        continuation.resume(returning: result)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
            task.resume()
        }
        return response
    }
}

private enum AuthorizationCodeRequest {
    case createCode

    var baseUrl: URL {
        Environment.current.authUrl
    }

    func asRequest() async throws -> URLRequest {
        var urlString = baseUrl.absoluteString
        urlString.append("/member-authorization-codes")
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        try await TokenRefresher.shared.refreshIfNeeded()
        let headers = await ApolloClient.headers()
        for element in headers {
            request.setValue(element.value, forHTTPHeaderField: element.key)
        }
        return request
    }
}
