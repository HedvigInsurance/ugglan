import Apollo
import Firebase
import Foundation
import hAnalytics
import hCore
import hGraphQL

extension AppDelegate {
    func setupHAnalytics() {
        hAnalyticsNetworking.httpAdditionalHeaders = {
            ApolloClient.headers(token: ApolloClient.retreiveToken()?.token) as [AnyHashable: Any]
        }
        hAnalyticsNetworking.endpointURL = {
            switch Environment.current {
            case .production:
                return "https://hanalytics-production.herokuapp.com"
            case .custom, .staging:
                return "https://hanalytics-staging.herokuapp.com"
            }
        }
        hAnalyticsNetworking.trackingId = { ApolloClient.getDeviceIdentifier() }
    }

    func setupHAnalyticsExperiments(numberOfTries: Int = 0) {
        log.info("Started loading hAnlyticsExperiments")
        hAnalyticsExperiment.load { success in
            if success {
                log.info("Successfully loaded hAnlyticsExperiments")
                ApplicationContext.shared.hasLoadedExperiments = true
            } else {
                log.info("Failed loading hAnlyticsExperiments, retries in \(numberOfTries * 100) ms")
                DispatchQueue.main.asyncAfter(deadline: .now() + (Double(numberOfTries) * 0.1)) {
                    self.setupHAnalyticsExperiments()
                }
            }
        }
    }
}
