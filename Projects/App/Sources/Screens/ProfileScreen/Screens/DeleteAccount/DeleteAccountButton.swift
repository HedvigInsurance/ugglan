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

struct DeleteAccountButton {  }

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
                bag += window.present(AppJourney.deleteAccountJourney)
            }
        }
        
        bag += deleteButton.onTapSignal.onValue { _ in
            presentDeleteAccountJourney()
        }
        
        bag += view.addArranged(deleteButton)
        
        return (view, bag)
    }
}
