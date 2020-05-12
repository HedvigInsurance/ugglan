//
//  OfferCoverage.swift
//  test
//
//  Created by sam on 25.3.20.
//

import Apollo
import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

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

        stackView.addArrangedSubview(UILabel(value: "Skyddet", style: .headlineLargeLargeCenter))
        bag += stackView.addArranged(MultilineLabel(value: "Hedvigs hemförsäkring erbjuder ett bra skydd för din lägenhet, dina saker och din familj när ni är på resa utomlands.", style: .bodySmallSmallCenter))

        let perilFragmentsSignal = client.fetch(query: OfferQuery()).valueSignal
            .compactMap { $0.data?.lastQuoteOfMember.asCompleteQuote?.perils.map { $0.fragments.perilFragment } }
            .plain()
            .readable(initial: [])

        bag += stackView.addArranged(ContractPerilCollection(presentDetailStyle: .modallyWithCloseButton, perilFragmentsSignal: perilFragmentsSignal))

        let insurableLimitFragmentsSignal = client.fetch(query: OfferQuery()).valueSignal
            .compactMap { $0.data?.lastQuoteOfMember.asCompleteQuote?.insurableLimits.map { $0.fragments.insurableLimitFragment } }
            .plain()
            .readable(initial: [])

        bag += stackView.addArranged(Spacing(height: 20))

        stackView.addArrangedSubview(UILabel(value: "Mer information", style: .headlineLargeLargeCenter))
        bag += stackView.addArranged(ContractInsurableLimits(insurableLimitFragmentsSignal: insurableLimitFragmentsSignal))

        return (stackView, bag)
    }
}
