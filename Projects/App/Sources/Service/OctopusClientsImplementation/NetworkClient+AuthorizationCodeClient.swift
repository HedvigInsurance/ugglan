import Apollo
import Authentication
import Environment
import Foundation
import hCore
import hGraphQL

extension NetworkClient: @retroactive AuthorizationCodeClient {
    public func getAuthorizationCode() async throws -> AuthorizationCodeCreationOutput {
        let request = try await AuthorizationCodeRequest.createCode.asRequest()
        let (data, response) = try await sessionClient.data(for: request)
        return try await handleResponseForced(data: data, response: response, error: nil)
    }
}

private enum AuthorizationCodeRequest {
    case createCode

    var baseUrl: URL {
        Environment.current.authUrl
    }

    func asRequest() async throws -> URLRequest {
        let url = baseUrl.appending(path: "member-authorization-codes")
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
