import UIKit
import hCore

@MainActor
enum SwishDeepLink {
    /// Needs `swish` listed under the app's `LSApplicationQueriesSchemes`, or iOS answers
    /// `false` however the device is set up. Read it per presentation rather than caching it:
    /// a member can leave to install Swish and come back to the same session.
    static var canOpen: Bool {
        guard let url = URL(string: "swish://") else { return false }
        return UIApplication.shared.canOpenURL(url)
    }

    static func open(_ urlString: String?) async {
        guard let url = urlString.flatMap(URL.init(string:)), UIApplication.shared.canOpenURL(url) else {
            return
        }
        await Dependencies.urlOpener.open(url)
    }
}
