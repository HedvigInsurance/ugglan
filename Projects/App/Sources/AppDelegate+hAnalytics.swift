import Apollo
import Foundation
import NotificationCenter
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

    func trackNotificationPermission() {
        UNUserNotificationCenter.current()
            .getNotificationSettings { settings in
                switch settings.authorizationStatus {
                case .authorized:
                    hAnalyticsEvent.notificationPermission(granted: true).send()
                case .denied:
                    hAnalyticsEvent.notificationPermission(granted: false).send()
                case .notDetermined, .ephemeral, .provisional:
                    hAnalyticsEvent.notificationPermission(granted: nil).send()
                @unknown default:
                    hAnalyticsEvent.notificationPermission(granted: nil).send()
                }
            }
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
                    self.setupHAnalyticsExperiments(numberOfTries: numberOfTries + 1)
                }
            }
        }
    }
}
