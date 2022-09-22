import Foundation
import hCore
import hGraphQL
import Apollo
import OdysseyKit

extension AppDelegate {
    func initOdyssey() {
        OdysseyKit.initialize(
            apiUrl: Environment.current.odysseyApiURL.absoluteString,
            authorizationToken: ApolloClient.retreiveToken()?.token ?? "",
            enableNetworkLogs: true
        )
    }
}
