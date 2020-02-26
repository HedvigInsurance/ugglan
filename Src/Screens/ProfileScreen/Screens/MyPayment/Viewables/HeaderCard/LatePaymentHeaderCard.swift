//
//  LatePaymentHeaderCard.swift
//  test
//
//  Created by Pavel Barros Quintanilla on 2020-01-23.
//

import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit

struct LatePaymentHeaderSection {
    @Inject var client: ApolloClient
    let failedCharges: Int
    let lastDate: String
}

extension LatePaymentHeaderSection: Viewable {
    func materialize(events _: ViewableEvents) -> (UIStackView, Disposable) {
        let bag = DisposeBag()
        let stackView = UIStackView()
        let childView = UIView()

        stackView.addSubview(childView)

        childView.layer.cornerRadius = 5
        childView.backgroundColor = .coral200

        childView.snp.makeConstraints { make in
            make.left.top.equalTo(stackView)
            make.right.equalTo(stackView)
            make.bottom.equalTo(stackView.safeAreaLayoutGuide)
        }

        let containerView = UIStackView()
        containerView.axis = .horizontal
        containerView.alignment = .top

        childView.addSubview(containerView)

        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(childView.safeAreaLayoutGuide)
            make.top.equalTo(childView).offset(15)
            make.bottom.equalTo(childView).offset(-15)
        }

        let icon = Icon(icon: Asset.pinkCircularExclamationPoint, iconWidth: 15)
        containerView.addArrangedSubview(icon)

        icon.snp.makeConstraints { make in
            make.width.equalTo(15)
            make.height.equalTo(20)
            make.left.equalTo(16)
        }

        containerView.setCustomSpacing(10, after: icon)

        let infoLabel = MultilineLabel(styledText: StyledText(text: String(key: .LATE_PAYMENT_MESSAGE(date: lastDate, months: failedCharges)), style: TextStyle.body.colored(UIColor.almostBlack)))

        bag += containerView.addArranged(infoLabel)

        return (stackView, bag)
    }
}
