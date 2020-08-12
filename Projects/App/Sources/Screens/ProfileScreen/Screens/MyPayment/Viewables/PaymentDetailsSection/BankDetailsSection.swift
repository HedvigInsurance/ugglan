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
import hCore
import hCoreUI
import hGraphQL

struct BankDetailsSection {
    @Inject var client: ApolloClient
}

extension BankDetailsSection: Viewable {
    func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
        let bag = DisposeBag()

        let section = SectionView(
            header: L10n.myPaymentBankRowLabel,
            footer: nil
        )
        let row = KeyValueRow()
        row.valueStyleSignal.value = .brand(.headline(color: .quartenary))

        bag += section.append(row)

        let dataValueSignal = client.watch(query: GraphQL.MyPaymentQuery())
        let noBankAccountSignal = dataValueSignal.filter {
            $0.data?.bankAccount == nil
        }

        bag += noBankAccountSignal.map {
            _ in L10n.myPaymentNotConnected
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
