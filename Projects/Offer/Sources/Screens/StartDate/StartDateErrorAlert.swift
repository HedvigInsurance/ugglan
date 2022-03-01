import Foundation
import Presentation
import hCore

extension JourneyPresentation {
    var startDateErrorAlert: some JourneyPresentation {
        self.onAction(OfferStore.self) { action in
            if case .failed(event: .updateStartDate) = action {
                Journey(
                    Alert<Void>(
                        title: L10n.offerSaveStartDateErrorAlertTitle,
                        message: L10n.offerSaveStartDateErrorAlertMessage,
                        actions: [.init(title: L10n.alertOk, action: { () })]
                    )
                )
            }
        }
    }
}
