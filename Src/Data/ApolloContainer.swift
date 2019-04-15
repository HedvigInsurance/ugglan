//
//  ApolloContainer.swift
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
import FirebaseRemoteConfig
import Flow
import Foundation

struct ApolloEnvironmentConfig {
    let endpointURL: URL
    let wsEndpointURL: URL
}

class ApolloContainer {
    static var shared = ApolloContainer()
    private let internalQueue = DispatchQueue(label: String(describing: ApolloContainer.self), qos: .default, attributes: .concurrent)

    private var _client: ApolloClient?
    private var _store: ApolloStore?

    var client: ApolloClient {
        get {
            return internalQueue.sync { _client! }
        }
        set(newState) {
            internalQueue.async(flags: .barrier) { self._client = newState }
        }
    }

    var store: ApolloStore {
        get {
            return internalQueue.sync { _store! }
        }
        set(newState) {
            internalQueue.async(flags: .barrier) { self._store = newState }
        }
    }

    private init() {}

    func createClient(token: String?, environment: ApolloEnvironmentConfig) -> (ApolloClient, ApolloStore) {
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

        let cache = InMemoryNormalizedCache()
        let store = ApolloStore(cache: cache)
        let client = ApolloClient(networkTransport: splitNetworkTransport, store: store)

        return (client, store)
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

    func createClientFromNewSession(environment: ApolloEnvironmentConfig) -> Future<(ApolloClient, ApolloStore)> {
        let campaign = CampaignInput(source: nil, medium: nil, term: nil, content: nil, name: nil)
        let mutation = CreateSessionMutation(campaign: campaign, trackingId: nil)

        return Future { completion in
            let (client, _) = self.createClient(token: nil, environment: environment)

            client.perform(mutation: mutation).onValue { result in
                if let token = result.data?.createSession {
                    self.saveToken(token: token)
                }

                let (clientWithSession, store) = self.createClient(
                    token: result.data?.createSession,
                    environment: environment
                )

                completion(.success((clientWithSession, store)))
            }

            return NilDisposer()
        }
    }

    func initClient(environment: ApolloEnvironmentConfig) -> Future<(ApolloClient, ApolloStore)> {
        return Future { completion in
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
                let (client, store) = self.createClient(token: tokenData!.token, environment: environment)

                self.client = client
                self.store = store

                completion(.success((client, store)))
            }

            return NilDisposer()
        }
    }
}
