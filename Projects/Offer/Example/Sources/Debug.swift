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
                Offer(
                    offerIDContainer: .stored,
                    menu: Menu(title: nil, children: [])
                ).withCloseButton,
                style: presentFullScreenSwitch.isOn ? .modally(presentationStyle: .fullScreen, transitionStyle: nil, capturesStatusBarAppearance: nil) : .detented(.large),
                options: presentWithLargeTitleSwitch.isOn ? [.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)] : [.defaults]
            )
        }

        bag += section.appendRow(title: "Swedish apartment").onValue {
            presentOffer(.makeSwedishApartment())
        }
        
        bag += section.appendRow(title: "Swedish house").onValue {
            presentOffer(
                .makeSwedishHouse(
                    bundleCost: .init(
                        monthlyGross: .init(amount: "100", currency: "SEK"),
                        monthlyDiscount: .init(amount: "0", currency: "SEK"),
                        monthlyNet: .init(amount: "100", currency: "SEK")
                    ),
                    redeemedCampaigns: []
                )
            )
        }
        
        bag += section.appendRow(title: "Swedish house - discounted").onValue {
            presentOffer(
                .makeSwedishHouse(
                    bundleCost: .init(
                        monthlyGross: .init(amount: "110", currency: "SEK"),
                        monthlyDiscount: .init(amount: "10", currency: "SEK"),
                        monthlyNet: .init(amount: "100", currency: "SEK")
                    ),
                    redeemedCampaigns: [
                        .init(displayValue: "-10 kr per month")
                    ]
                )
            )
        }
        
        bag += section.appendRow(title: "Swedish house - discounted indefinite").onValue {
            presentOffer(
                .makeSwedishHouse(
                    bundleCost: .init(
                        monthlyGross: .init(amount: "110", currency: "SEK"),
                        monthlyDiscount: .init(amount: "27.5", currency: "SEK"),
                        monthlyNet: .init(amount: "82.5", currency: "SEK")
                    ),
                    redeemedCampaigns: [
                        .init(displayValue: "-25% forever")
                    ]
                )
            )
        }
        
        bag += section.appendRow(title: "Swedish house - discounted free months").onValue {
            presentOffer(
                .makeSwedishHouse(
                    bundleCost: .init(
                        monthlyGross: .init(amount: "110", currency: "SEK"),
                        monthlyDiscount: .init(amount: "110", currency: "SEK"),
                        monthlyNet: .init(amount: "0", currency: "SEK")
                    ),
                    redeemedCampaigns: [
                        .init(displayValue: "3 free months")
                    ]
                )
            )
        }
        
        bag += section.appendRow(title: "Swedish house - discounted percentage for months").onValue {
            presentOffer(
                .makeSwedishHouse(
                    bundleCost: .init(
                        monthlyGross: .init(amount: "110", currency: "SEK"),
                        monthlyDiscount: .init(amount: "27.5", currency: "SEK"),
                        monthlyNet: .init(amount: "82.5", currency: "SEK")
                    ),
                    redeemedCampaigns: [
                        .init(displayValue: "25% discount for 3 months")
                    ]
                )
            )
        }
        
        bag += section.appendRow(title: "Norwegian bundle").onValue {
            presentOffer(.makeNorwegianBundle())
        }

        bag += viewController.install(form)

        return (viewController, bag)
    }
}
