//
//  ApolloClient.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-14.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Apollo
import Disk
import Foundation

class CreateApolloClient {
    private static func createClient(token: String?) -> ApolloClient {
        let authPayloads = [
            "Authorization": token ?? ""
        ]

        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = authPayloads

        let authMap: GraphQLMap = authPayloads

        let endpointURL = URL(string: "http://localhost:4000/graphql")!
        let wsEndpointURL = URL(string: "ws://localhost:4000/subscriptions")!
        let httpNetworkTransport = HTTPNetworkTransport(url: endpointURL, configuration: configuration)
        let websocketNetworkTransport = WebSocketTransport(
            request: URLRequest(url: wsEndpointURL),
            connectingPayload: authMap
        )

        let splitNetworkTransport = SplitNetworkTransport(
            httpNetworkTransport: httpNetworkTransport,
            webSocketNetworkTransport: websocketNetworkTransport
        )

        return ApolloClient(networkTransport: splitNetworkTransport)
    }

    static func create(onCreate: @escaping (_ apolloClient: ApolloClient) -> Void) {
        let tokenData = try? Disk.retrieve(
            "authorization-token.json",
            from: .applicationSupport,
            as: AuthorizationToken.self
        )

        let apolloClient = CreateApolloClient.createClient(token: tokenData?.token ?? nil)

        if tokenData == nil {
            let campaign = CampaignInput(source: nil, medium: nil, term: nil, content: nil, name: nil)
            let mutation = CreateSessionMutation(campaign: campaign, trackingId: nil)

            apolloClient.perform(mutation: mutation) { result, _ in
                let newApolloClient = CreateApolloClient.createClient(token: result?.data?.createSession)
                onCreate(newApolloClient)
            }
        }

        onCreate(apolloClient)
    }
}

var apollo: ApolloClient?
