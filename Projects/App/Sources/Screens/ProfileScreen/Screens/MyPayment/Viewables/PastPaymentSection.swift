//
//  PastPaymentSection.swift
//  production
//
//  Created by Sam Pettersson on 2020-01-15.
//

import Apollo
import Flow
import Form
import Foundation
import hCore
import Presentation
import UIKit

struct PastPaymentsSection {
    @Inject var client: ApolloClient
    let presentingViewController: UIViewController
}

extension PastPaymentsSection: Viewable {
    func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
        let bag = DisposeBag()

        let section = SectionView(
            header: L10n.paymentsSubtitlePaymentHistory,
            footer: nil,
            style: .sectionPlain
        )

        let dataValueSignal = client.watch(query: MyPaymentQuery())
        bag += dataValueSignal.map { $0.data?.chargeHistory.isEmpty ?? true }.bindTo(section, \.isHidden)

        let dataSignal = dataValueSignal.compactMap { $0.data }

        bag += dataSignal.onValueDisposePrevious { data -> Disposable? in
            let innerBag = DisposeBag()

            innerBag += data.chargeHistory.prefix(2).map { chargeHistory -> Disposable in
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

            let moreRow = RowView()
            moreRow.append(UILabel(value: L10n.paymentsBtnHistory, style: .rowTitle))

            let arrow = Icon(frame: .zero, icon: Asset.chevronRight, iconWidth: 20)

            moreRow.append(arrow)

            arrow.snp.makeConstraints { make in
                make.width.equalTo(20)
            }

            innerBag += section.append(moreRow).onValue { _ in
                self.presentingViewController.present(PaymentsHistory())
            }

            innerBag += {
                section.remove(moreRow)
            }

            return innerBag
        }

        return (section, bag)
    }
}
