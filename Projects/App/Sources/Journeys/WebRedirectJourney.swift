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
    static func webRedirect(url: URL) -> some JourneyPresentation {
        ContinueJourney()
            .onPresent {
                let urlPrefix = "https://www."
                var urlToOpen: URL {
                    if !url.absoluteString.contains("https://") {
                        let urlStringWithPrefix = urlPrefix + url.absoluteString
                        if let urlWithPrefix = URL(string: urlStringWithPrefix) {
                            return urlWithPrefix
                        }
                    }
                    return url
                }
                UIApplication.shared.open(urlToOpen)
            }
    }
}
