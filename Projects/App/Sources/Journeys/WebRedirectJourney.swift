import Embark
import Flow
import Foundation
import Presentation
import UIKit
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

extension AppJourney {
    @JourneyBuilder
    static func webRedirect(url: String) -> some JourneyPresentation {
        ContinueJourney()
            .onPresent {
                var webUrl = Environment.current.webBaseURL
                webUrl.appendPathComponent(Localization.Locale.currentLocale.webPath)
                webUrl.appendPathComponent("new-member")
                webUrl =
                    webUrl
                    .appending("utm_source", value: "ios")
                    .appending("utm_medium", value: "hedvig-app")
                    .appending("utm_campaign", value: Localization.Locale.currentLocale.market.rawValue.lowercased())

                if let urlObject = URL(string: url) {
                    UIApplication.shared.open(urlObject)
                }

                hAnalyticsEvent.redirectedToWebOnboarding().send()
            }
    }
}
