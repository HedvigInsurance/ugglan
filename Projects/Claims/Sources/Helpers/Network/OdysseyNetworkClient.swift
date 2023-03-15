import Foundation
import hGraphQL

public final class OdysseyNetworkClient {
    let sessionClient: URLSession
    public init() {
        let config = URLSessionConfiguration.default
        self.sessionClient = URLSession(configuration: config)
    }
}
