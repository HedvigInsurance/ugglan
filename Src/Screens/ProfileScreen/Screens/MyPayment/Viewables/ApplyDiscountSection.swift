//
//  ApplyDiscountSection.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-06-18.
//

import Apollo
import Flow
import Form
import Foundation

struct ApplyDiscountSection {
    let client: ApolloClient
    let presentingViewController: UIViewController

    init(presentingViewController: UIViewController, client: ApolloClient = ApolloContainer.shared.client) {
        self.presentingViewController = presentingViewController
        self.client = client
    }
}

extension ApplyDiscountSection: Viewable {
    func materialize(events _: ViewableEvents) -> (ButtonSection, Disposable) {
        let bag = DisposeBag()

        let buttonSection = ButtonSection(text: String(key: .REFERRAL_ADDCOUPON_HEADLINE), style: .normal)

        bag += buttonSection.onSelect.onValue { _ in
            let overlay = DraggableOverlay(
                presentable: ApplyDiscount(),
                presentationOptions: [.defaults, .prefersNavigationBarHidden(true)]
            )
            self.presentingViewController.present(overlay)
        }

        return (buttonSection, bag)
    }
}
