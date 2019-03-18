//
//  ApolloClient.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-14.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Apollo
#if canImport(ApolloWebSocket)
    import ApolloWebSocket
#endif
import Disk
import Flow
import Foundation
import FirebaseRemoteConfig

struct HedvigApolloEnvironmentConfig {
    let endpointURL: URL
    let wsEndpointURL: URL
}

class HedvigApolloClient {
    static var shared = HedvigApolloClient()
    var client: ApolloClient?
    var store: ApolloStore?
    var remoteConfig: RemoteConfig?

    private init() {
    }

    func createClient(token: String?, environment: HedvigApolloEnvironmentConfig) -> Future<(ApolloClient, ApolloStore)> {
        let authPayloads = [
            "Authorization": token ?? "",
        ]

        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = authPayloads

        let authMap: GraphQLMap = authPayloads

        let httpNetworkTransport = HTTPNetworkTransport(
            url: environment.endpointURL,
            configuration: configuration
        )

        let websocketNetworkTransport = WebSocketTransport(
            request: URLRequest(url: environment.wsEndpointURL),
            connectingPayload: authMap
        )

        let splitNetworkTransport = SplitNetworkTransport(
            httpNetworkTransport: httpNetworkTransport,
            webSocketNetworkTransport: websocketNetworkTransport
        )

        return Future { completion in
            let cache = InMemoryNormalizedCache()
            let store = ApolloStore(cache: cache)
            let client = ApolloClient(networkTransport: splitNetworkTransport, store: store)
            completion(Result.success((client, store)))
            return Disposer {}
        }
    }

    func retreiveToken() -> AuthorizationToken? {
        return try? Disk.retrieve(
            "authorization-token.json",
            from: .applicationSupport,
            as: AuthorizationToken.self
        )
    }

    func saveToken(token: String) {
        let authorizationToken = AuthorizationToken(token: token)
        try? Disk.save(
            authorizationToken,
            to: .applicationSupport,
            as: "authorization-token.json"
        )
    }

    func createClientFromNewSession(environment: HedvigApolloEnvironmentConfig) -> Future<(ApolloClient, ApolloStore)> {
        let campaign = CampaignInput(source: nil, medium: nil, term: nil, content: nil, name: nil)
        let mutation = CreateSessionMutation(campaign: campaign, trackingId: nil)

        return Future { completion in
            self.createClient(token: nil, environment: environment).onValue { client, _ in
                client.perform(mutation: mutation).onValue { result in
                    if let token = result.data?.createSession {
                        self.saveToken(token: token)
                    }

                    self.createClient(
                        token: result.data?.createSession,
                        environment: environment
                    ).onValue { clientWithSession, store in
                        completion(Result.success((clientWithSession, store)))
                    }.onError { error in
                        completion(Result.failure(error))
                    }
                }
            }

            return NilDisposer()
        }
    }

    func initClient(environment: HedvigApolloEnvironmentConfig) -> Future<(ApolloClient, ApolloStore)> {
        return Future { completion in
            if let client = self.client, let store = self.store {
                completion(.success((client, store)))
                return Disposer {
                    self.client = nil
                    self.store = nil
                }
            }

            let tokenData = self.retreiveToken()

            if tokenData == nil {
                self.createClientFromNewSession(environment: environment).onResult { result in
                    switch result {
                    case let .success((client, store)): do {
                        self.client = client
                        self.store = store
                        completion(result)
                    }
                    case .failure: do {
                        completion(result)
                    }
                    }
                }
            } else {
                self.createClient(token: tokenData!.token, environment: environment).onResult { result in
                    switch result {
                    case let .success((client, store)): do {
                        self.client = client
                        self.store = store
                        completion(result)
                    }
                    case .failure: do {
                        completion(result)
                    }
                    }
                }
            }

            return Disposer {
                self.client = nil
                self.store = nil
            }
        }
    }
}
