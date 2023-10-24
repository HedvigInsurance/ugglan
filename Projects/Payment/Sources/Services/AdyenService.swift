import Apollo
import Flow
import Foundation
import hCore
import hGraphQL

public protocol AdyenService {
    func getAdyenUrl() async throws -> URL
}

extension PaymentNetworkClient: AdyenService {
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

// replace with global network client when merged with chat
final public class PaymentNetworkClient {
    let sessionClient: URLSession
    public init() {
        let config = URLSessionConfiguration.default
        self.sessionClient = URLSession(configuration: config)
    }

    func handleResponse<T>(data: Data?, response: URLResponse?, error: Error?) throws -> T? where T: Decodable {
        if error != nil {
            throw NetworkError.networkError(message: L10n.General.errorBody)
        }

        guard let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode)
        else {
            if let data {
                let responseError = try? JSONDecoder().decode(ResponseError.self, from: data)
                throw NetworkError.badRequest(message: responseError?.message)
            }
            throw NetworkError.badRequest(message: nil)
        }

        guard let responseData = data else {
            return nil
        }

        do {
            let response = try JSONDecoder().decode(T.self, from: responseData)
            return response
        } catch let error {
            throw NetworkError.parsingError(message: error.localizedDescription)
        }
    }
}

enum NetworkError: Error {
    case networkError(message: String)
    case badRequest(message: String?)
    case parsingError(message: String)
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return message
        case .badRequest(let message):
            return message
        case .parsingError(let message):
            return message
        }
    }
}
struct ResponseError: Decodable {
    let timestamp: Int
    let status: Int
    let error: String
    let message: String
    let requestId: String
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
                    var headers = ApolloClient.headers()
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
