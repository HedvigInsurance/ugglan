import Apollo
import ApolloWebSocket
import Disk
import Flow
import Foundation
import hCore
import hGraphQL
import UIKit

extension ApolloClient {
    static var environment: ApolloEnvironmentConfig {
        ApplicationState.getTargetEnvironment().apolloEnvironmentConfig
    }

    static var userAgent: String {
        "\(Bundle.main.bundleIdentifier ?? "") \(Bundle.main.appVersion) (iOS \(UIDevice.current.systemVersion))"
    }

    static var cache = InMemoryNormalizedCache()

    static func createClient(token: String?) -> (ApolloStore, ApolloClient) {
        let httpAdditionalHeaders = [
            "Authorization": token ?? "",
            "Accept-Language": Localization.Locale.currentLocale.acceptLanguageHeader,
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

        Dependencies.shared.add(module: Module { () -> ApolloClient in
            client
        })

        Dependencies.shared.add(module: Module { () -> ApolloStore in
            store
        })

        Dependencies.shared.add(module: Module { () -> ApolloEnvironmentConfig in
            environment
        })

        return (store, client)
    }

    static func deleteToken() {
        try? Disk.remove(
            "authorization-token.json",
            from: .applicationSupport
        )
    }

    static func retreiveToken() -> AuthorizationToken? {
        try? Disk.retrieve(
            "authorization-token.json",
            from: .applicationSupport,
            as: AuthorizationToken.self
        )
    }

    static func saveToken(token: String) {
        let authorizationToken = AuthorizationToken(token: token)
        try? Disk.save(
            authorizationToken,
            to: .applicationSupport,
            as: "authorization-token.json"
        )
    }

    static func createClientFromNewSession() -> Future<Void> {
        ApplicationState.setLastNewsSeen()

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

            client.perform(mutation: mutation).onValue { data in
                self.saveToken(token: data.createSession)

                _ = self.createClient(
                    token: data.createSession
                )

                completion(.success)
            }

            return NilDisposer()
        }
    }

    static func initClient() -> Future<Void> {
        Future { completion in
            let tokenData = self.retreiveToken()

            if tokenData == nil {
                self.createClientFromNewSession().onResult { result in
                    switch result {
                    case .success: do {
                        completion(.success)
                    }
                    case let .failure(error): do {
                        completion(.failure(error))
                    }
                    }
                }
            } else {
                _ = self.createClient(token: tokenData!.token)
                completion(.success)
            }

            return NilDisposer()
        }
    }
}
