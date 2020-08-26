//
//  OfferCoverage.swift
//  test
//
//  Created by sam on 25.3.20.
//

import Apollo
import Contracts
import Flow
import Foundation
import hCore
import hCoreUI
import hGraphQL
import Presentation
import UIKit

struct OfferCoverage {
    @Inject var client: ApolloClient
}

extension OfferCoverage: Viewable {
    func materialize(events _: ViewableEvents) -> (UIStackView, Disposable) {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.layoutMargins = UIEdgeInsets(horizontalInset: 15, verticalInset: 30)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.spacing = 20

        let bag = DisposeBag()

        stackView.addArrangedSubview(UILabel(value: L10n.offerScreenCoverageTitle, style: .headlineLargeLargeCenter))

        let bodyLabel = MultilineLabel(value: "", style: .bodySmallSmallCenter)
        bag += stackView.addArranged(bodyLabel)

        bag += client.fetch(query: GraphQL.OfferQuery()).valueSignal.compactMap { $0.data?.insurance.type }.onValue { type in
            switch type {
            case .brf, .studentBrf:
                bodyLabel.valueSignal.value = L10n.offerScreenCoverageBodyBrf
            case .rent, .studentRent:
                bodyLabel.valueSignal.value = L10n.offerScreenCoverageBodyRental
            case .house:
                bodyLabel.valueSignal.value = L10n.offerScreenCoverageBodyHouse
            case .__unknown:
                break
            }
        }

        let perilFragmentsSignal = client.fetch(query: GraphQL.OfferQuery()).valueSignal
            .compactMap { $0.data?.lastQuoteOfMember.asCompleteQuote?.perils.map { $0.fragments.perilFragment } }
            .plain()
            .readable(initial: [])

        bag += stackView.addArranged(ContractPerilCollection(perilFragmentsSignal: perilFragmentsSignal))

        let insurableLimitFragmentsSignal = client.fetch(query: GraphQL.OfferQuery()).valueSignal
            .compactMap { $0.data?.lastQuoteOfMember.asCompleteQuote?.insurableLimits.map { $0.fragments.insurableLimitFragment } }
            .plain()
            .readable(initial: [])

        bag += stackView.addArranged(Spacing(height: 20))

        stackView.addArrangedSubview(UILabel(value: L10n.offerScreenInsuredAmountsTitle, style: .headlineLargeLargeCenter))
        bag += stackView.addArranged(ContractInsurableLimits(insurableLimitFragmentsSignal: insurableLimitFragmentsSignal))

        return (stackView, bag)
    }
}
