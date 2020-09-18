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
