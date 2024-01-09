import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

extension AppJourney {
    @JourneyBuilder
    static func webRedirect(url: URL) -> some JourneyPresentation {
        ContinueJourney()
            .onPresent {
                UIApplication.shared.open(url)
            }
    }
}
