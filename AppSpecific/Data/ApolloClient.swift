//
//  ApolloContainer.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-14.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Apollo
import ApolloWebSocket
import Disk
import Flow
import Foundation

struct ApolloEnvironmentConfig {
    let endpointURL: URL
    let wsEndpointURL: URL
    let assetsEndpointURL: URL
}

extension ApolloClient {
    static var environment: ApolloEnvironmentConfig {
        #if APP_VARIANT_PRODUCTION
            return ApolloEnvironmentConfig(
                endpointURL: URL(string: "https://giraffe.hedvig.com/graphql")!,
                wsEndpointURL: URL(string: "wss://giraffe.hedvig.com/subscriptions")!,
                assetsEndpointURL: URL(string: "https://giraffe.hedvig.com")!
            )
        #elseif APP_VARIANT_DEV
            return ApolloEnvironmentConfig(
                endpointURL: URL(string: "https://graphql.dev.hedvigit.com/graphql")!,
                wsEndpointURL: URL(string: "wss://graphql.dev.hedvigit.com/subscriptions")!,
                assetsEndpointURL: URL(string: "https://graphql.dev.hedvigit.com")!
            )
        #endif
    }

    static func createClient(token: String?) -> (ApolloStore, ApolloClient) {
        let httpAdditionalHeaders = [
            "Authorization": token ?? "",
            "Accept-Language": Localization.Locale.currentLocale.acceptLanguageHeader,
            "User-Agent": "\(Bundle.main.bundleIdentifier ?? "") \(Bundle.main.appVersion) (iOS \(UIDevice.current.systemVersion))",
        ]

        let configuration = URLSessionConfiguration.default

        configuration.httpAdditionalHeaders = httpAdditionalHeaders

        let session = URLSession(configuration: configuration)

        let httpNetworkTransport = HTTPNetworkTransport(
            url: environment.endpointURL,
            session: session
        )

        let websocketNetworkTransport = WebSocketTransport(
            request: URLRequest(url: environment.wsEndpointURL),
            connectingPayload: httpAdditionalHeaders as GraphQLMap
        )

        let splitNetworkTransport = SplitNetworkTransport(
            httpNetworkTransport: httpNetworkTransport,
            webSocketNetworkTransport: websocketNetworkTransport
        )

        let cache = InMemoryNormalizedCache()
        let store = ApolloStore(cache: cache)
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
        return try? Disk.retrieve(
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

        let campaign = CampaignInput(
            source: nil,
            medium: nil,
            term: nil,
            content: nil,
            name: nil
        )
        let mutation = CreateSessionMutation(campaign: campaign, trackingId: nil)

        return Future { completion in
            let (_, client) = self.createClient(token: nil)

            client.perform(mutation: mutation).onValue { result in
                if let token = result.data?.createSession {
                    self.saveToken(token: token)
                }

                let _ = self.createClient(
                    token: result.data?.createSession
                )

                completion(.success)
            }

            return NilDisposer()
        }
    }

    static func initClient() -> Future<Void> {
        return Future { completion in
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
                let _ = self.createClient(token: tokenData!.token)
                completion(.success)
            }

            return NilDisposer()
        }
    }
}
