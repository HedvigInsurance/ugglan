import Apollo
import Form
import Foundation
import NotificationCenter
import hAnalytics
import hCore
import hGraphQL

extension AppDelegate {
    func setupHAnalytics() {
        hAnalyticsNetworking.httpAdditionalHeaders = {
            ApolloClient.headers() as [AnyHashable: Any]
        }
        hAnalyticsNetworking.endpointURL = {
            switch Environment.current {
            case .production:
                return "https://hanalytics.prod.hedvigit.com"
            case .custom, .staging:
                return "https://hanalytics.dev.hedvigit.com"
            }
        }
        hAnalyticsNetworking.trackingId = { ApolloClient.getDeviceIdentifier() }
    }
    
    func setupHAnalyticsExperiments() {
        hAnalyticsExperiment.retryingLoad { success in
            DefaultStyling.installCustom()
            ApplicationContext.shared.hasLoadedExperiments = success
        }
    }
}
