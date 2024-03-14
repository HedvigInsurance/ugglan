import Apollo
import Flow
import Foundation
import hCore
import hGraphQL

public protocol AdyenService {
    func getAdyenUrl() async throws -> URL
}

extension NetworkClient: AdyenService {
    public func getAdyenUrl() async throws -> URL {
        let request = try await AdyenRequest.getAuthorizationCode.asRequest()
        let (data, response) = try await self.sessionClient.data(for: request)
        do {
            let responseModel: AuthorizationModel? = try self.handleResponse(
                data: data,
                response: response,
                error: nil
            )
            if let url = responseModel?.paymentUrl {
                return url
            } else {
                throw NetworkError.parsingError(message: L10n.General.errorBody)
            }
        } catch _ {
            throw NetworkError.parsingError(message: L10n.General.errorBody)
        }
    }
}

enum AdyenRequest {
    case getAuthorizationCode

    var baseUrl: URL {
        return Environment.current.authUrl
    }

    var methodType: String {
        switch self {
        case .getAuthorizationCode:
            return "POST"
        }
    }

    func asRequest() async throws -> URLRequest {
        var request: URLRequest!
        switch self {
        case .getAuthorizationCode:
            var baseUrlString = baseUrl.absoluteString
            baseUrlString.append("/member-authorization-codes")
            let url = URL(string: baseUrlString)!
            request = URLRequest(url: url)
        }
        request.httpMethod = self.methodType
        try await TokenRefresher.shared.refreshIfNeeded()
        let headers = ApolloClient.headers()
        headers.forEach { element in
            request.setValue(element.value, forHTTPHeaderField: element.key)
        }
        return request

    }
}

struct AuthorizationModel: Codable {
    let authorizationCode: String

    var paymentUrl: URL? {
        let url =
            "\(Environment.current.webBaseURL)/\(Localization.Locale.currentLocale.webPath)/payment/connect-legacy/start?authorizationCode=\(authorizationCode)"
        return URL(string: url)
    }
}
