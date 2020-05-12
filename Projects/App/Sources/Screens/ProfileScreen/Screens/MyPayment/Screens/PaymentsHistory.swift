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
import Presentation
import UIKit
import hCore

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
            footer: nil,
            style: .sectionPlain
        )

        let dataValueSignal = client.watch(query: MyPaymentQuery())
        let dataSignal = dataValueSignal.compactMap { $0.data }

        bag += dataSignal.onValueDisposePrevious { data -> Disposable? in
            let innerBag = DisposeBag()

            innerBag += data.chargeHistory.map { chargeHistory -> Disposable in
                let row = KeyValueRow()
                row.valueStyleSignal.value = .rowTitleDisabled

                let dateParsingFormatter = DateFormatter()
                dateParsingFormatter.dateFormat = "yyyy-MM-dd"

                if let date = dateParsingFormatter.date(from: chargeHistory.date) {
                    let dateDisplayFormatter = DateFormatter()
                    dateDisplayFormatter.dateFormat = "dd MMMM, yyyy"

                    row.keySignal.value = dateDisplayFormatter.string(from: date)
                }

                row.valueSignal.value = chargeHistory.amount.fragments.monetaryAmountFragment.formattedAmount

                return section.append(row)
            }

            return innerBag
        }

        return (viewController, bag)
    }
}
