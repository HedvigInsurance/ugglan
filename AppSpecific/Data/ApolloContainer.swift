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
    let assetsEndpointURL: URL
}

class ApolloContainer {
    static let shared = ApolloContainer()

    private var _client: ApolloClient?
    private var _store: ApolloStore?
    private var _environment: ApolloEnvironmentConfig?

    var client: ApolloClient {
        return _client!
    }

    var store: ApolloStore {
        return _store!
    }

    var environment: ApolloEnvironmentConfig {
        get {
            return _environment!
        }
        set(newValue) {
            _environment = newValue
        }
    }

    private init() {}

    func createClient(token: String?) {
        let httpAdditionalHeaders = [
            "Authorization": token ?? "",
            "Accept-Language": Localization.Locale.currentLocale.acceptLanguageHeader,
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
        _store = ApolloStore(cache: cache)
        _client = ApolloClient(networkTransport: splitNetworkTransport, store: store)
    }

    func deleteToken() {
        try? Disk.remove(
            "authorization-token.json",
            from: .applicationSupport
        )
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

    func createClientFromNewSession() -> Future<Void> {
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
            self.createClient(token: nil)

            self.client.perform(mutation: mutation).onValue { result in
                if let token = result.data?.createSession {
                    self.saveToken(token: token)
                }

                self.createClient(
                    token: result.data?.createSession
                )

                completion(.success)
            }

            return NilDisposer()
        }
    }

    func initClient() -> Future<Void> {
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
                self.createClient(token: tokenData!.token)
                completion(.success)
            }

            return NilDisposer()
        }
    }
}
