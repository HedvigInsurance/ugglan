//
//  ContractTableHeader.swift
//  test
//
//  Created by sam on 27.3.20.
//

import Flow
import Foundation
import hCore
import UIKit

struct ContractTableHeader {
    let presentingViewController: UIViewController
}

extension ContractTableHeader: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let containerView = UIStackView()
        containerView.axis = .vertical
        containerView.spacing = 15

        let bag = DisposeBag()

        let chatPreview = ChatPreview(presentingViewController: presentingViewController)
        bag += containerView.addArranged(chatPreview)

        let paymentNeedsSetupSection = PaymentNeedsSetupSection(presentingViewController: presentingViewController)
        bag += containerView.addArranged(paymentNeedsSetupSection)

        let importantMessagesSection = ImportantMessagesSection(presentingViewController: presentingViewController)
        bag += containerView.addArranged(importantMessagesSection)

        return (containerView, bag)
    }
}
