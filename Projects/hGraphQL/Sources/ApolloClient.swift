import Apollo
import ApolloWebSocket
import Disk
import Flow
import Foundation
import UIKit

extension ApolloClient {
    public static var environment: ApolloEnvironmentConfig?
    public static var acceptLanguageHeader: String = ""
    public static var bundle: Bundle?

    static var appVersion: String {
        bundle?.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
    }

    public static var userAgent: String {
        "\(bundle?.bundleIdentifier ?? "") \(appVersion) (iOS \(UIDevice.current.systemVersion))"
    }

    public static var cache = InMemoryNormalizedCache()

    static func createClient(token: String?) -> (ApolloStore, ApolloClient) {
        guard let environment = environment else {
            fatalError("Environment must be defined")
        }
        let httpAdditionalHeaders = [
            "Authorization": token ?? "",
            "Accept-Language": acceptLanguageHeader,
            "User-Agent": userAgent,
        ]

        let configuration = URLSessionConfiguration.default

        configuration.httpAdditionalHeaders = httpAdditionalHeaders

        let urlSessionClient = URLSessionClient(sessionConfiguration: configuration)

        let httpNetworkTransport = HTTPNetworkTransport(
            url: environment.endpointURL,
            client: urlSessionClient
        )

        let websocketNetworkTransport = WebSocketTransport(
            request: URLRequest(url: environment.wsEndpointURL),
            connectingPayload: httpAdditionalHeaders as GraphQLMap
        )

        let splitNetworkTransport = SplitNetworkTransport(
            httpNetworkTransport: httpNetworkTransport,
            webSocketNetworkTransport: websocketNetworkTransport
        )

        let store = ApolloStore(cache: ApolloClient.cache)
        let client = ApolloClient(networkTransport: splitNetworkTransport, store: store)

        return (store, client)
    }

    public static func deleteToken() {
        try? Disk.remove(
            "authorization-token.json",
            from: .applicationSupport
        )
    }

    public static func retreiveToken() -> AuthorizationToken? {
        try? Disk.retrieve(
            "authorization-token.json",
            from: .applicationSupport,
            as: AuthorizationToken.self
        )
    }

    public static func saveToken(token: String) {
        let authorizationToken = AuthorizationToken(token: token)
        try? Disk.save(
            authorizationToken,
            to: .applicationSupport,
            as: "authorization-token.json"
        )
    }

    public static func createClientFromNewSession() -> Future<(ApolloStore, ApolloClient)> {
        let campaign = GraphQL.CampaignInput(
            source: nil,
            medium: nil,
            term: nil,
            content: nil,
            name: nil
        )
        let mutation = GraphQL.CreateSessionMutation(campaign: campaign, trackingId: nil)

        return Future { completion in
            let (_, client) = self.createClient(token: nil)

            client.perform(mutation: mutation) { result in
                switch result {
                case let .success(result):
                    guard let data = result.data else {
                        return
                    }

                    self.saveToken(token: data.createSession)

                    let result = self.createClient(
                        token: data.createSession
                    )

                    completion(.success(result))
                case let .failure(error):
                    completion(.failure(error))
                }
            }

            return Disposer {
                _ = client
            }
        }
    }

    public static func initClient() -> Future<(ApolloStore, ApolloClient)> {
        Future { completion in
            let tokenData = self.retreiveToken()

            if tokenData == nil {
                return self.createClientFromNewSession().onResult { result in
                    switch result {
                    case let .success(result):
                        completion(.success(result))
                    case let .failure(error):
                        completion(.failure(error))
                    }
                }.disposable
            } else {
                let result = self.createClient(token: tokenData!.token)
                completion(.success(result))
            }

            return NilDisposer()
        }
    }
}
