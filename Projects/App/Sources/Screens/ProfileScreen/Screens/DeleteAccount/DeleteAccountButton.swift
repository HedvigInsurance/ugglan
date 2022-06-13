import Apollo
import Flow
import Form
import Presentation
import SwiftUI
import UIKit
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

struct DeleteAccountButton {
    let memberDetails: MemberDetails
}

extension DeleteAccountButton: Viewable {
    func materialize(events: ViewableEvents) -> (UIStackView, Disposable) {
        let bag = DisposeBag()
        let view = UIStackView()

        view.axis = .vertical
        view.spacing = 0
        view.alignment = .center
        bag += view.addArranged(Spacing(height: 49))

        let deleteButton = Button(
            title: "Delete account",
            type: .transparentLarge(textColor: .brand(.destructive))
        )

        func presentDeleteAccountJourney() {
            if let window = view.viewController {
                let hasAlreadyRequested = ApolloClient.deleteAccountStatus(for: memberDetails.id)
                if hasAlreadyRequested {
                    bag += window.present(AppJourney.deleteRequestAlreadyPlacedJourney)
                } else {
                    bag += window.present(AppJourney.deleteAccountJourney(details: memberDetails))
                }
            }
        }

        bag += deleteButton.onTapSignal.onValue { _ in
            presentDeleteAccountJourney()
        }

        bag += view.addArranged(deleteButton)

        return (view, bag)
    }
}
