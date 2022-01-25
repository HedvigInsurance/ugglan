import Apollo
import Firebase
import Foundation
import hAnalytics
import hCore
import hGraphQL

extension AppDelegate {
    func setupHAnalytics() {
        hAnalyticsNetworking.httpAdditionalHeaders = { ApolloClient.headers(token: ApolloClient.retreiveToken()?.token) as [AnyHashable: Any] }
        hAnalyticsNetworking.endpointURL = {
            switch Environment.current {
            case .production:
                return "https://hanalytics-production.herokuapp.com/event"
            case .custom, .staging:
                return "https://hanalytics-staging.herokuapp.com/event"
            }
        }
        hAnalyticsNetworking.trackingId = { ApolloClient.getDeviceIdentifier() }
    }
}
