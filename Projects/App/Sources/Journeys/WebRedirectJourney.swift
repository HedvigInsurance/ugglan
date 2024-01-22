import Flow
import Foundation
import Presentation
import SafariServices
import UIKit
import hCore
import hCoreUI
import hGraphQL

extension AppJourney {
    @JourneyBuilder
    static func webRedirect(url: URL) -> some JourneyPresentation {
        ContinueJourney()
            .onPresent {
                var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false)
                if urlComponent?.scheme == nil {
                    urlComponent?.scheme = "https"
                }
                let schema = urlComponent?.scheme
                if let finalUrl = urlComponent?.url {
                    if schema == "https" || schema == "http" {
                        let vc = SFSafariViewController(url: finalUrl)
                        vc.modalPresentationStyle = .pageSheet
                        vc.preferredControlTintColor = .brand(.primaryText())
                        UIApplication.shared.getTopViewController()?.present(vc, animated: true)
                    } else {
                        UIApplication.shared.open(url)
                    }
                }
            }
    }
}
