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
import UIKit

struct ApolloEnvironmentConfig {
    let endpointURL: URL
    let wsEndpointURL: URL
    let assetsEndpointURL: URL
}

extension ApolloClient {
    static var environment: ApolloEnvironmentConfig {
        ApplicationState.getTargetEnvironment().apolloEnvironmentConfig
    }
    
    static var userAgent: String {
        return "\(Bundle.main.bundleIdentifier ?? "") \(Bundle.main.appVersion) (iOS \(UIDevice.current.systemVersion))"
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

                _ = self.createClient(
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
                _ = self.createClient(token: tokenData!.token)
                completion(.success)
            }

            return NilDisposer()
        }
    }
}
