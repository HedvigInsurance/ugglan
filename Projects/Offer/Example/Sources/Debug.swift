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
        
        let presentFullScreenRow = section.appendRow(title: "Present in full screen")
        let presentFullScreenSwitch = UISwitch()
        presentFullScreenRow.append(presentFullScreenSwitch)
        
        let presentWithLargeTitlesRow = section.appendRow(title: "Present with large titles")
        let presentWithLargeTitleSwitch = UISwitch()
        presentWithLargeTitlesRow.append(presentWithLargeTitleSwitch)
        
        func presentOffer(_ body: JSONObject) {
            let apolloClient = ApolloClient(networkTransport: MockNetworkTransport(body: body), store: ApolloStore())

            Dependencies.shared.add(module: Module { () -> ApolloClient in
                apolloClient
            })

            viewController.present(
                Offer(ids: []).withCloseButton,
                style: presentFullScreenSwitch.isOn ? .modally(presentationStyle: .fullScreen, transitionStyle: nil, capturesStatusBarAppearance: nil) : .detented(.large),
                options: presentWithLargeTitleSwitch.isOn ? [.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)] : [.defaults]
            )
        }

        bag += section.appendRow(title: "Swedish apartment").onValue {
            presentOffer(.makeSwedishApartment())
        }
        
        bag += section.appendRow(title: "Swedish house").onValue {
            presentOffer(.makeSwedishHouse())
        }
        
        bag += section.appendRow(title: "Norwegian bundle").onValue {
            presentOffer(.makeNorwegianBundle())
        }

        bag += viewController.install(form)

        return (viewController, bag)
    }
}
