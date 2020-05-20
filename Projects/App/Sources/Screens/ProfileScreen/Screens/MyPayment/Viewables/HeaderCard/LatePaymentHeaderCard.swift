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
import hCore
import hCoreUI

struct LatePaymentHeaderSection {
    @Inject var client: ApolloClient
    let failedCharges: Int
    let lastDate: String
}

extension LatePaymentHeaderSection: Viewable {
    func materialize(events _: ViewableEvents) -> (UIStackView, Disposable) {
        let bag = DisposeBag()
        let view = UIStackView()
        let childView = UIView()

        view.addSubview(childView)

        childView.layer.cornerRadius = 5
        childView.backgroundColor = .coral200

        childView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }

        let containerView = UIStackView()
        containerView.axis = .horizontal
        containerView.alignment = .top
        containerView.edgeInsets = UIEdgeInsets(horizontalInset: 16, verticalInset: 20)

        childView.addSubview(containerView)

        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(childView.safeAreaLayoutGuide)
            make.top.bottom.equalToSuperview()
        }

        let icon = Icon(icon: Asset.pinkCircularExclamationPoint, iconWidth: 15)
        containerView.addArrangedSubview(icon)

        icon.snp.makeConstraints { make in
            make.width.equalTo(15)
            make.height.equalTo(20)
            make.left.equalTo(16)
        }

        containerView.setCustomSpacing(10, after: icon)

        let infoLabel = MultilineLabel(styledText: StyledText(text: L10n.paymentsLatePaymentsMessage(self.failedCharges, self.lastDate),
                                                              style: TextStyle.body.colored(UIColor.almostBlack)))
        bag += containerView.addArranged(infoLabel)

        return (view, bag)
    }
}
