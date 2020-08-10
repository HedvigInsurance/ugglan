//
//  ApolloEnvironmentConfig.swift
//  hCore
//
//  Created by sam on 29.7.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation

public struct ApolloEnvironmentConfig {
    public let endpointURL: URL
    public let wsEndpointURL: URL
    public let assetsEndpointURL: URL

    public init(endpointURL: URL, wsEndpointURL: URL, assetsEndpointURL: URL) {
        self.endpointURL = endpointURL
        self.wsEndpointURL = wsEndpointURL
        self.assetsEndpointURL = assetsEndpointURL
    }
}
