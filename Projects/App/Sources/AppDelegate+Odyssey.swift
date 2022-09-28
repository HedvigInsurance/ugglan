import Apollo
import Foundation
import OdysseyKit
import hCore
import hGraphQL

extension AppDelegate {
    func initOdyssey() {
        OdysseyKit.initialize(
            apiUrl: Environment.current.odysseyApiURL.absoluteString,
            authorizationToken: ApolloClient.retreiveToken()?.token ?? "",
            enableNetworkLogs: true
        )
    }
}
