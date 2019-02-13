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

struct BankDetailsSection {
    let client: ApolloClient

    init(client: ApolloClient = HedvigApolloClient.shared.client!) {
        self.client = client
    }
}

extension BankDetailsSection: Viewable {
    func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
        let bag = DisposeBag()

        let section = SectionView(
            header: String(.MY_PAYMENT_BANK_ROW_LABEL),
            footer: nil,
            style: .sectionPlain
        )

        let row = KeyValueRow()
        row.valueStyleSignal.value = .rowTitleDisabled
        
        bag += section.append(row)

        let dataValueSignal = client.fetch(query: MyPaymentQuery()).valueSignal
        let noBankAccountSignal = dataValueSignal.filter {
            $0.data?.bankAccount == nil
        }

        bag += noBankAccountSignal.map {
            _ in String(.MY_PAYMENT_NOT_CONNECTED)
        }.bindTo(row.keySignal)

        let dataSignal = dataValueSignal.compactMap { $0.data }

        bag += dataSignal.compactMap {
            $0.bankAccount?.bankName
        }.bindTo(row.keySignal)

        bag += dataSignal.compactMap {
            $0.bankAccount?.descriptor
        }.bindTo(row.valueSignal)

        return (section, bag)
    }
}
