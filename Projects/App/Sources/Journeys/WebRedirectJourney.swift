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
                let url = URL(string: url.absoluteString.replacingOccurrences(of: "https://", with: ""))!
                var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false)
                if urlComponent?.scheme == nil {
                    urlComponent?.scheme = "https"
                }
                if let finalUrl = urlComponent?.url {
                    if urlComponent?.scheme == "tel" {
                        UIApplication.shared.open(url)
                    } else {
                        let vc = SFSafariViewController(url: finalUrl)
                        vc.modalPresentationStyle = .pageSheet
                        vc.preferredControlTintColor = .brand(.primaryText())
                        UIApplication.shared.getTopViewController()?.present(vc, animated: true)
                    }
                }
            }
    }
}
