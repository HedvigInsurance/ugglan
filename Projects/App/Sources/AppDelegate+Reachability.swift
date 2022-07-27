import Foundation
import hCore
import hCoreUI

extension AppDelegate {
    func setupReachabilityListeners() {
        NetworkReachability.sharedInstance.observeReachability()
        NetworkReachability.sharedInstance.whenUnreachable = { _ in
            Toasts.shared.displayToast(
                toast: Toast(
                    symbol: .icon(hCoreUIAssets.warningTriangle.image),
                    body: "No network connection",
                    duration: 100,
                    hideSignal: NetworkReachability.sharedInstance.reachableSignal
                )
            )
        }
    }
}
