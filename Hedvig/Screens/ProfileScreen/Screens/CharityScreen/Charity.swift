//
//  Charity.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-21.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Apollo
import Flow
import Form
import Foundation
import Presentation

struct Charity {
    let client: ApolloClient
    let presentingViewController: UIViewController

    init(
        client: ApolloClient = HedvigApolloClient.shared.client!,
        presentingViewController: UIViewController
    ) {
        self.client = client
        self.presentingViewController = presentingViewController
    }
}

extension Charity: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()
        let viewController = UIViewController()
        viewController.title = String.translation(.MY_CHARITY_SCREEN_TITLE)

        let containerView = UIView()
        containerView.backgroundColor = .offWhite

        let charityPicker = CharityPicker(presentingViewController: presentingViewController)
        bag += containerView.add(charityPicker) { view in
            view.snp.makeConstraints({ make in
                make.edges.equalToSuperview()
            })
        }.onValue({ _ in
            let selectedCharity = SelectedCharity(animateEntry: true)
            bag += containerView.add(selectedCharity) { view in
                view.snp.makeConstraints({ make in
                    make.edges.equalToSuperview()
                })
            }
        })

        viewController.view = containerView

        return (viewController, bag)
    }
}
