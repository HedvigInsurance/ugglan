import Embark
import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL
import hAnalytics

extension AppJourney {
    @JourneyBuilder
    static func onboarding() -> some JourneyPresentation {
        ContinueJourney().onPresent {
            var webUrl = Environment.current.webBaseURL
            webUrl.appendPathComponent(Localization.Locale.currentLocale.webPath)
            webUrl.appendPathComponent("new-member")
            webUrl = webUrl.appending("utm_source", value: "hedvigIOSApp")
            
            UIApplication.shared.open(webUrl)
            
            hAnalyticsEvent.redirectedToWebOnboarding().send()
        }
    }
}
