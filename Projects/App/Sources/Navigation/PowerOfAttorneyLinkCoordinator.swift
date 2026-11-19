import SwiftUI
import hCore
import hCoreUI

/// Handles a shared power of attorney link (`/poa?id=`). The link logs in the person it was granted to, so it only
/// works logged out: when logged in, the member is asked to log out first and the login opens once they have.
@MainActor
final class PowerOfAttorneyLinkCoordinator {
    private weak var mainVm: MainNavigationViewModel?

    init(mainVm: MainNavigationViewModel) {
        self.mainVm = mainVm
    }

    func handle(_ url: URL, isColdStart: Bool) {
        guard let mainVm, let id = url.getParameter(property: .id), !id.isEmpty else { return }
        // Same settle time as other deep links: on a cold start the launch is still running
        let delay: Double = isColdStart ? 2 : 0.2
        if mainVm.stateToShow == .notLoggedIn {
            openLoginWhenLoggedOut(id: id, after: delay)
        } else {
            mainVm.whenShowing(mainVm.stateToShow, after: delay, storingIn: \.powerOfAttorneyLinkCancellable) {
                [weak self] in
                self?.confirmLogout(id: id)
            }
        }
    }

    private func openLoginWhenLoggedOut(id: String, after delay: Double) {
        guard let mainVm else { return }
        mainVm.whenShowing(.notLoggedIn, after: delay, storingIn: \.powerOfAttorneyLinkCancellable) {
            [weak mainVm] in
            mainVm?.notLoggedInVm.startPowerOfAttorneyLogin(id: id)
        }
    }

    /// Presented with UIKit so it shows above any sheet presented with `.detent`, which a SwiftUI alert can't.
    private func confirmLogout(id: String, name: String? = nil) {
        guard let presenter = UIApplication.shared.getTopViewController() else { return }
        let title: String = {
            if let name {
                return "Do you want to switch to \(name)?"
            } else {
                return "Do you want to switch?"
            }
        }()
        let alert = UIAlertController(
            // TODO: Localize via Lokalise
            title: title,
            // TODO: Localize via Lokalise
            message: "You are logged in. To log in with this power of attorney link you need to log out first.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: L10n.logoutAlertActionCancel, style: .cancel))
        alert.addAction(
            UIAlertAction(title: L10n.logoutAlertActionConfirm, style: .destructive) { [weak self] _ in
                // Registered before logging out, so it waits for the logged out screen to show
                self?.openLoginWhenLoggedOut(id: id, after: 0.5)
                ApplicationState.preserveState(.notLoggedIn)
                ApplicationState.state = .notLoggedIn
            }
        )
        presenter.present(alert, animated: true)
    }
}
