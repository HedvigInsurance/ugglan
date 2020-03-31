//
//  CardDetailsSection.swift
//  test
//
//  Created by Sam Pettersson on 2020-03-30.
//

import Apollo
import Flow
import Form
import Foundation

struct CardDetailsSection {
    @Inject var client: ApolloClient
}

extension CardDetailsSection: Viewable {
    func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
        let bag = DisposeBag()

        let section = SectionView(
            header: String(key: .MY_PAYMENT_CARD_ROW_LABEL),
            footer: nil,
            style: .sectionPlain
        )
        section.isHidden = true

        let row = KeyValueRow()
        row.valueStyleSignal.value = .rowTitleDisabled

        bag += section.append(row)

        let dataValueSignal = client.watch(query: ActivePaymentMethodsQuery())
        let dataSignal = dataValueSignal.compactMap { $0.data }
        
        bag += dataSignal.map { $0.activePaymentMethods == nil }.bindTo(
            animate: SpringAnimationStyle.lightBounce(),
            section,
            \.animationSafeIsHidden
        )

        bag += dataSignal.compactMap {
            $0.activePaymentMethods?.storedPaymentMethodsDetails.brand?.capitalized
        }.bindTo(row.keySignal)

        bag += dataSignal.compactMap {
            $0.activePaymentMethods?.storedPaymentMethodsDetails.lastFourDigits
        }.map { "**** \($0)" }.bindTo(row.valueSignal)

        return (section, bag)
    }
}
