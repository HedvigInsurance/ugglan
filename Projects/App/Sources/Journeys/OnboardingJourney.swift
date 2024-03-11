import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

extension AppJourney {
    static func onboarding() -> some JourneyPresentation {
        ContinueJourney()
            .onPresent {
                var webUrl = Environment.current.webBaseURL
                webUrl.appendPathComponent(Localization.Locale.currentLocale.webPath)
                webUrl.appendPathComponent(Localization.Locale.currentLocale.priceQoutePath)
                webUrl =
                    webUrl
                    .appending("utm_source", value: "ios")
                    .appending("utm_medium", value: "hedvig-app")
                    .appending("utm_campaign", value: Localization.Locale.currentLocale.market.rawValue.lowercased())
                UIApplication.shared.open(webUrl)
            }
    }
}
