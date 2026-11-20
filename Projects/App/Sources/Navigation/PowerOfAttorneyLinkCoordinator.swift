import PowerOfAttorneyCore
import SwiftUI
import hCore
import hCoreUI

/// Handles a shared power of attorney link (`/poa?id=`). The link logs in the person it was granted to. Logged out, the
/// login opens right away. Logged in, the member confirms the switch first; they stay logged in during the login, and
/// only once it succeeds is their session swapped for the power of attorney one.
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
                Task { [weak self] in
                    let name = await self?.granterName(forPowerOfAttorneyId: id)
                    self?.confirmSwitch(id: id, name: name)
                }
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

    /// The name of the member who granted the power of attorney. Whoever opens the link is the person it was granted
    /// to, so it's among their received ones. `nil` when it can't be found in time (e.g. in a power of attorney session,
    /// which can't list them), then the alert just doesn't name the account.
    private func granterName(forPowerOfAttorneyId id: String) async -> String? {
        let lookup = Task {
            let received = try? await PowerOfAttorneyService().getReceivedPowerOfAttorneys()
            return received?.first { $0.id == id }?.name
        }
        // The alert doesn't wait longer than this for the name: cancelling fails the request, so the lookup gives nil
        let timeout = Task {
            try? await Task.sleep(for: .seconds(2))
            lookup.cancel()
        }
        let name = await lookup.value
        timeout.cancel()
        return name
    }

    /// Presented with UIKit so it shows above any sheet presented with `.detent`, which a SwiftUI alert can't.
    private func confirmSwitch(id: String, name: String? = nil) {
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
            message: name.map { "Log in with BankID to switch. You will be switched to \($0)'s account." }
                ?? "Log in with BankID to switch account.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: L10n.logoutAlertActionCancel, style: .cancel))
        alert.addAction(
            UIAlertAction(title: L10n.generalContinueButton, style: .default) { [weak mainVm] _ in
                mainVm?.startPowerOfAttorneySwitch(id: id)
            }
        )
        presenter.present(alert, animated: true)
    }
}
