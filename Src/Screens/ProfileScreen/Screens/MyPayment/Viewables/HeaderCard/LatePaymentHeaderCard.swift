//
//  LatePaymentHeaderCard.swift
//  test
//
//  Created by Pavel Barros Quintanilla on 2020-01-23.
//

import Foundation
import Flow
import Presentation
import UIKit
import Apollo
import Form

struct LatePaymentHeaderSection {
    @Inject var client: ApolloClient
    let failedCharges: Int
    let lastDate: String
}

extension LatePaymentHeaderSection: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let view = UIView()
        let childView = UIView()
        view.addSubview(childView)
        childView.layer.cornerRadius = 5
        childView.backgroundColor = .coral200
        
        childView.snp.makeConstraints { make in
            make.left.top.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
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
            make.left.equalTo(15)
            make.top.equalTo(0)
        }
        
        containerView.setCustomSpacing(15, after: icon)
        
        let infoLabel = MultilineLabel(value: String(key: .LATE_PAYMENT_MESSAGE(date: self.failedCharges, months: self.lastDate)), style: .body)
        bag += containerView.addArranged(infoLabel)

        return (view, bag)
    }
}
