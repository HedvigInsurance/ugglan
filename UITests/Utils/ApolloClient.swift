//
//  ApolloContainer.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-07-22.
//

import Apollo
import ApolloWebSocket
import Disk
import FirebaseRemoteConfig
import Flow
import Foundation

struct ApolloEnvironmentConfig {
    let endpointURL: URL
    let wsEndpointURL: URL
    let assetsEndpointURL: URL
}


extension ApolloClient {
    static let initialRecords: RecordSet = [:]

    static var networkTransport: MockNetworkTransport {
        return MockNetworkTransport(body: [
            "data": [
               
            ],
        ])
    }

    static var environment = ApolloEnvironmentConfig(
        endpointURL: URL(string: "http://localhost:4000/graphql")!,
        wsEndpointURL: URL(string: "wss://graphql.dev.hedvigit.com/subscriptions")!,
        assetsEndpointURL: URL(string: "https://graphql.dev.hedvigit.com")!
    )

    static func createClientFromNewSession() -> Future<ApolloClient> {
        return initClient()
    }
    
    static func initClient() -> Future<ApolloClient> {
        let cache = InMemoryNormalizedCache(records: initialRecords)
        let store = ApolloStore(cache: cache)

        WebSocketTransport.provider = MockWebSocket.self
        let websocketTransport = WebSocketTransport(request: URLRequest(url: URL(string: "http://localhost/dummy_url")!))

        let splitNetworkTransport = SplitNetworkTransport(
            httpNetworkTransport: networkTransport,
            webSocketNetworkTransport: websocketTransport
        )

        let client = ApolloClient(networkTransport: splitNetworkTransport, store: store)
        
        Dependencies.shared.add(module: Module { () -> ApolloClient in
            client
        })
        
        Dependencies.shared.add(module: Module { () -> ApolloStore in
            store
        })
        
        return Future(client)
    }
}
