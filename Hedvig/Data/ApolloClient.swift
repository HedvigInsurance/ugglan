//
//  ApolloClient.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-14.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Apollo
import Foundation

let apollo: ApolloClient = {
    let authPayloads = [
        "Authorization": "AbkEvCcPlNo1Fw==.g3VxF4tpxT99bw==.2A0Yl/M9YVlBkQ=="
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
}()
