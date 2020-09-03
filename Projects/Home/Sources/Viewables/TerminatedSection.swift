//
//  TerminatedSection.swift
//  Home
//
//  Created by sam on 1.9.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
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

struct TerminatedSection {
    @Inject var client: ApolloClient
}

extension TerminatedSection: Viewable {
    func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
        let bag = DisposeBag()
        let section = SectionView()
        section.dynamicStyle = .brandGrouped(separatorType: .none)

        let titleLabel = MultilineLabel(
            value: "",
            style: .brand(.largeTitle(color: .primary))
        )
        bag += section.append(titleLabel)

        section.appendSpacing(.inbetween)

        client.fetch(query: GraphQL.HomeQuery()).onValue { data in
            titleLabel.valueSignal.value = L10n.HomeTab.terminatedWelcomeTitle(data.member.firstName ?? "")
        }

        let subtitleLabel = MultilineLabel(
            value: L10n.HomeTab.terminatedBody,
            style: .brand(.body(color: .secondary))
        )
        bag += section.append(subtitleLabel)

        section.appendSpacing(.top)

        let button = Button(
            title: L10n.HomeTab.claimButtonText,
            type: .standardOutline(
                borderColor: .brand(.secondaryButtonBackgroundColor),
                textColor: .brand(.secondaryButtonBackgroundColor)
            )
        )
        bag += section.append(button)

        bag += button.onTapSignal.compactMap { section.viewController }.onValue(Home.openClaimsHandler)

        return (section, bag)
    }
}
