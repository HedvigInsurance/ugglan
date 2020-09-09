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
import hCore
import hCoreUI
import hGraphQL
import Presentation
import UIKit

struct Charity {
    @Inject var client: ApolloClient
}

extension Charity: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()
        let viewController = UIViewController()
        viewController.title = L10n.myCharityScreenTitle
        
        let scrollView = FormScrollView()
        let form = FormView()

        bag += client.watch(query: GraphQL.SelectedCharityQuery())
            .map { $0.cashback }
            .buffer()
            .onValueDisposePrevious { cashbacks in
                guard let cashback = cashbacks.last else { return NilDisposer() }
                
                let innerBag = DisposeBag()

                if cashback != nil {
                    scrollView.isScrollEnabled = true
                    let selectedCharity = SelectedCharity(animateEntry: cashbacks.count > 1, presentingViewController: viewController)
                    innerBag += form.append(selectedCharity)
                } else {
                    scrollView.isScrollEnabled = false
                    let charityPicker = CharityPicker(
                        presentingViewController: viewController
                    )
                    innerBag += scrollView.add(charityPicker) { table in
                        table.snp.makeConstraints { make in
                            make.edges.equalToSuperview()
                            make.height.width.equalToSuperview()
                        }
                    }.onValue { _ in
                        bag += self.client.fetch(
                            query: GraphQL.SelectedCharityQuery(),
                            cachePolicy: .fetchIgnoringCacheData
                        ).disposable
                    }
                }
                
                return innerBag
            }

        bag += viewController.install(form, scrollView: scrollView)

        return (viewController, bag)
    }
}
