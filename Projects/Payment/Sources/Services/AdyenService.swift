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
        return try await withCheckedThrowingContinuation {
            (inCont: CheckedContinuation<URL, Error>) -> Void in
            AdyenRequest.getAuthorizationCode.asRequest.onValue { [weak self] request in
                let task = self?.sessionClient
                    .dataTask(
                        with: request,
                        completionHandler: { [weak self] (data, response, error) in
                            do {
                                if let data: AuthorizationModel = try self?
                                    .handleResponse(data: data, response: response, error: error)
                                {
                                    if let paymentUrl = data.paymentUrl {
                                        inCont.resume(with: .success(paymentUrl))
                                    } else {
                                        inCont.resume(
                                            throwing: NetworkError.parsingError(message: L10n.General.errorBody)
                                        )
                                    }
                                }
                            } catch let error {
                                inCont.resume(throwing: error)
                            }
                        }
                    )
                task?.resume()
            }
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

    var asRequest: Future<URLRequest> {
        var request: URLRequest!
        switch self {
        case .getAuthorizationCode:
            var baseUrlString = baseUrl.absoluteString
            baseUrlString.append("/member-authorization-codes")
            let url = URL(string: baseUrlString)!
            request = URLRequest(url: url)
        }
        request.httpMethod = self.methodType
        return Future { completion in
            TokenRefresher.shared.refreshIfNeeded()
                .onValue {
                    let headers = ApolloClient.headers()
                    headers.forEach { element in
                        request.setValue(element.value, forHTTPHeaderField: element.key)
                    }
                    completion(.success(request))
                }
            return NilDisposer()
        }
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
