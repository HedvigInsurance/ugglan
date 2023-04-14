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

    func setupHAnalyticsExperiments() {
        hAnalyticsExperiment.retryingLoad { success in
            DefaultStyling.installCustom()
            ApplicationContext.shared.hasLoadedExperiments = success
        }
    }
}
