//
//  ApolloClient.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-14.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Apollo
import Disk
import Flow
import Foundation

struct HedvigApolloEnvironmentConfig {
    let endpointURL: URL
    let wsEndpointURL: URL
}

class HedvigApolloClient {
    static var shared = HedvigApolloClient()
    var client: ApolloClient?

    private init() {}

    func createClient(token: String?, environment: HedvigApolloEnvironmentConfig) -> Future<ApolloClient> {
        let authPayloads = [
            "Authorization": token ?? ""
        ]

        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = authPayloads

        let authMap: GraphQLMap = authPayloads

        let httpNetworkTransport = HTTPNetworkTransport(url: environment.endpointURL, configuration: configuration)
        let websocketNetworkTransport = WebSocketTransport(
            request: URLRequest(url: environment.wsEndpointURL),
            connectingPayload: authMap
        )

        let splitNetworkTransport = SplitNetworkTransport(
            httpNetworkTransport: httpNetworkTransport,
            webSocketNetworkTransport: websocketNetworkTransport
        )

        return Future { completion in
            let client = ApolloClient(networkTransport: splitNetworkTransport)
            completion(Result.success(client))
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

    func createClientFromNewSession(environment: HedvigApolloEnvironmentConfig) -> Future<ApolloClient> {
        let campaign = CampaignInput(source: nil, medium: nil, term: nil, content: nil, name: nil)
        let mutation = CreateSessionMutation(campaign: campaign, trackingId: nil)

        return Future { completion in
            self.createClient(token: nil, environment: environment).onValue { client in
                client.perform(mutation: mutation).onValue { result in
                    self.createClient(
                        token: result.data?.createSession,
                        environment: environment
                    ).onValue { clientWithSession in
                        completion(Result.success(clientWithSession))
                    }.onError { error in
                        completion(Result.failure(error))
                    }
                }
            }

            return NilDisposer()
        }
    }

    func initClient(environment: HedvigApolloEnvironmentConfig) -> Future<ApolloClient> {
        return Future { completion in
            if self.client != nil {
                completion(.success(self.client!))
                return Disposer {
                    self.client = nil
                }
            }

            let tokenData = self.retreiveToken()

            if tokenData == nil {
                self.createClientFromNewSession(environment: environment).onResult { result in
                    switch result {
                    case let .success(client): do {
                        self.client = client
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
                    case let .success(client): do {
                        self.client = client
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
            }
        }
    }
}
