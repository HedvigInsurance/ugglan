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
        viewController.title = String(.MY_CHARITY_SCREEN_TITLE)

        let containerView = UIView()
        containerView.backgroundColor = .offWhite

        bag += client.watch(query: SelectedCharityQuery())
            .map { $0.data?.cashback }
            .buffer()
            .onValue { cashbacks in
                guard let cashback = cashbacks.last else { return }

                for view in containerView.subviews {
                    view.removeFromSuperview()
                }

                if cashback != nil {
                    let selectedCharity = SelectedCharity(animateEntry: cashbacks.count > 1)
                    bag += containerView.add(selectedCharity) { view in
                        view.snp.makeConstraints({ make in
                            make.edges.equalToSuperview()
                        })
                    }
                } else {
                    let charityPicker = CharityPicker(
                        presentingViewController: self.presentingViewController
                    )
                    bag += containerView.add(charityPicker) { view in
                        view.snp.makeConstraints({ make in
                            make.edges.equalToSuperview()
                        })
                    }.onValue({ _ in
                        bag += self.client.fetch(
                            query: SelectedCharityQuery(),
                            cachePolicy: .fetchIgnoringCacheData
                        ).disposable
                    })
                }
            }

        viewController.view = containerView

        return (viewController, bag)
    }
}
