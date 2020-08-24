//
//  ActiveSection.swift
//  Home
//
//  Created by Sam Pettersson on 2020-08-17.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Apollo
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import UIKit

struct ActiveSection {
    @Inject var client: ApolloClient
}

extension ActiveSection: Viewable {
    func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
        let bag = DisposeBag()
        let section = SectionView()
        section.dynamicStyle = .brandGrouped(separatorType: .none)

        let label = MultilineLabel(
            value: "",
            style: .brand(.largeTitle(color: .primary))
        )
        bag += section.append(label)

        client.fetch(query: GraphQL.HomeQuery()).compactMap { $0.data }.onValue { homeData in
            label.valueSignal.value = L10n.HomeTab.welcomeTitle(homeData.member.firstName ?? "")
        }

        section.appendSpacing(.top)

        let button = Button(
            title: L10n.HomeTab.claimButtonText,
            type: .standard(
                backgroundColor: .brand(.primaryButtonBackgroundColor),
                textColor: .brand(.primaryButtonTextColor
                )
            )
        )
        bag += section.append(button)

        bag += button.onTapSignal.compactMap { section.viewController }.onValue(Home.openClaimsHandler)

        section.appendSpacing(.inbetween)

        bag += section.append(CommonClaimsCollection())

        return (section, bag)
    }
}
