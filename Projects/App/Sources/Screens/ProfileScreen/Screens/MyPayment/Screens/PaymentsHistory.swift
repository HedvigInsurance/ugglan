//
//  PaymentsHistory.swift
//  production
//
//  Created by Sam Pettersson on 2020-01-15.
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

struct PaymentsHistory {
    @Inject var client: ApolloClient
}

extension PaymentsHistory: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        viewController.title = L10n.paymentHistoryTitle
        let bag = DisposeBag()

        let form = FormView()
        bag += viewController.install(form)

        let section = form.appendSection(
            header: nil,
            footer: nil
        )

        let dataValueSignal = client.watch(query: GraphQL.MyPaymentQuery())
        let dataSignal = dataValueSignal.compactMap { $0.data }

        bag += dataSignal.onValueDisposePrevious { data -> Disposable? in
            let innerBag = DisposeBag()

            innerBag += data.chargeHistory.map { chargeHistory -> Disposable in
                let row = KeyValueRow()
                row.valueStyleSignal.value = .brand(.headline(color: .quartenary))

                let dateParsingFormatter = DateFormatter()
                dateParsingFormatter.dateFormat = "yyyy-MM-dd"

                if let date = dateParsingFormatter.date(from: chargeHistory.date) {
                    let dateDisplayFormatter = DateFormatter()
                    dateDisplayFormatter.dateFormat = "dd MMMM, yyyy"

                    row.keySignal.value = dateDisplayFormatter.string(from: date)
                }

                row.valueSignal.value = chargeHistory.amount.fragments.monetaryAmountFragment.monetaryAmount.formattedAmount

                return section.append(row)
            }

            return innerBag
        }

        return (viewController, bag)
    }
}
