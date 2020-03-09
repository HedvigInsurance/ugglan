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
import Common
import Space

struct BankDetailsSection {
    @Inject var client: ApolloClient
    let isHiddenSignal = ReadWriteSignal<Bool>(false)
}

extension BankDetailsSection: Viewable {
    func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
        let bag = DisposeBag()

        let section = SectionView(
            header: String(key: .MY_PAYMENT_BANK_ROW_LABEL),
            footer: nil,
            style: .sectionPlain
        )
        bag += isHiddenSignal.bindTo(section, \.isHidden)

        let row = KeyValueRow()
        row.valueStyleSignal.value = .rowTitleDisabled

        bag += section.append(row)

        let dataValueSignal = client.watch(query: MyPaymentQuery())
        let noBankAccountSignal = dataValueSignal.filter {
            $0.data?.bankAccount == nil
        }

        bag += noBankAccountSignal.map {
            _ in String(key: .MY_PAYMENT_NOT_CONNECTED)
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
