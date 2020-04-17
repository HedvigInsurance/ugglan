//
//  PaymentHeaderNextCharge.swift
//  production
//
//  Created by Sam Pettersson on 2020-01-17.
//

import Apollo
import Flow
import Form
import Foundation
import UIKit

struct PaymentHeaderNextCharge {
    @Inject var client: ApolloClient
}

extension PaymentHeaderNextCharge: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let view = UIView()
        let bag = DisposeBag()
        view.layer.cornerRadius = 5

        let contentContainer = UIStackView()
        contentContainer.layoutMargins = UIEdgeInsets(inset: 5)
        contentContainer.isLayoutMarginsRelativeArrangement = true
        contentContainer.distribution = .equalSpacing
        view.addSubview(contentContainer)

        let label = UILabel(value: "", style: .bodyText)
        contentContainer.addArrangedSubview(label)

        contentContainer.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(2)
            make.bottom.equalToSuperview().offset(-2)
        }

        bag += client.watch(query: MyPaymentQuery()).map { $0.data?.nextChargeDate }.onValue { nextChargeDate in
            if let nextChargeDate = nextChargeDate {
                let dateParsingFormatter = DateFormatter()
                dateParsingFormatter.dateFormat = "yyyy-MM-dd"

                if let date = dateParsingFormatter.date(from: nextChargeDate) {
                    let dateDisplayFormatter = DateFormatter()
                    dateDisplayFormatter.dateFormat = "dd MMMM"
                    label.value = dateDisplayFormatter.string(from: date)
                }

                view.backgroundColor = .primaryBackground
            } else {
                label.value = String(key: .PAYMENTS_CARD_NO_STARTDATE)
                label.textColor = .darkGray
                view.backgroundColor = .sunflower300
            }
        }

        return (view, bag)
    }
}
