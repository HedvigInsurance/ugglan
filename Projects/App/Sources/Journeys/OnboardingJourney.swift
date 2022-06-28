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
    static func onboarding() -> some JourneyPresentation {
        ContinueJourney()
            .onPresent {
                var webUrl = Environment.current.webBaseURL
                webUrl.appendPathComponent(Localization.Locale.currentLocale.webPath)
                webUrl.appendPathComponent("new-member")
                webUrl = webUrl.appending("utm_source", value: "hedvigIOSApp")

                UIApplication.shared.open(webUrl)

                hAnalyticsEvent.redirectedToWebOnboarding().send()
            }
    }
}
