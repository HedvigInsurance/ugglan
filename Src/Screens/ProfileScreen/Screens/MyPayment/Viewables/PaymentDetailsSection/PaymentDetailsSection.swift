//
//  PaymentDetailsSection.swift
//  Hedvig
//
//  Created by Isaac Sennerholt on 2019-01-15.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Apollo
import Flow
import Form
import Foundation

struct PaymentDetailsSection {
    let client: ApolloClient

    init(client: ApolloClient = HedvigApolloClient.shared.client!) {
        self.client = client
    }
}

extension PaymentDetailsSection: Viewable {
    func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
        let bag = DisposeBag()

        let section = SectionView(
            header: String(.MY_PAYMENT_PAYMENT_ROW_LABEL),
            footer: nil,
            style: .sectionPlain
        )

        let row = KeyValueRow()
        row.keySignal.value = String(.MY_PAYMENT_TYPE)
        row.valueStyleSignal.value = .rowTitleDisabled

        let dataValueSignal = client.fetch(query: MyPaymentQuery()).valueSignal

        bag += dataValueSignal.compactMap {
            $0.data?.chargeDate
        }.map { paymentDate in
            return String(.MY_PAYMENT_DATE(paymentDate: paymentDate))
        }.bindTo(row.valueSignal)

        bag += section.append(row)

        return (section, bag)
    }
}
