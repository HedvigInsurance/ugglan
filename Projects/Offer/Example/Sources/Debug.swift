//
//  Debug.swift
//  OfferExample
//
//  Created by Sam Pettersson on 2021-04-19.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Flow
import Offer
import Form
import Foundation
import Presentation
import UIKit
import hGraphQL
import hCore
import Apollo
import TestingUtil
import OfferTesting

struct Debug {}

extension Debug: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        viewController.title = "Offer Example"

        let bag = DisposeBag()

        let form = FormView()

        let section = form.appendSection(headerView: UILabel(value: "Offer", style: .default), footerView: nil)
        
        func presentOffer(_ body: JSONObject) {
            let apolloClient = ApolloClient(networkTransport: MockNetworkTransport(body: body), store: ApolloStore())

            Dependencies.shared.add(module: Module { () -> ApolloClient in
                apolloClient
            })

            viewController.present(
                Offer(ids: []),
                style: .detented(.large),
                options: [.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)]
            )
        }


        bag += section.appendRow(title: "Test").onValue {
            presentOffer(.makeSwedishApartment())
        }

        bag += viewController.install(form)

        return (viewController, bag)
    }
}
