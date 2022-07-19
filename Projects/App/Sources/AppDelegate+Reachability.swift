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
                    duration: nil
                )
            )
        }
        
        //TODO: Handle hiding the toast when network is back online
        NetworkReachability.sharedInstance.whenReachable = { _ in
            Toasts.shared.displayToast(
                toast: Toast(
                    symbol: .icon(hCoreUIAssets.warningTriangle.image),
                    body: "Back online",
                    duration: 0.001
                )
            )
        }
    }
}
