//
//  ReferralsMoreInfo.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-06-17.
//

import Flow
import Foundation
import Presentation
import UIKit
import ComponentKit

struct ReferralsMoreInfo {}

extension ReferralsMoreInfo: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let bag = DisposeBag()

        let viewController = UIViewController()

        let containerStackView = UIStackView()
        bag += containerStackView.applySafeAreaBottomLayoutMargin()

        let containerView = UIStackView()
        containerView.spacing = 15
        containerView.backgroundColor = UIColor.hedvig(.white)
        containerView.axis = .vertical
        containerView.layoutMargins = UIEdgeInsets(horizontalInset: 15, verticalInset: 24)
        containerView.isLayoutMarginsRelativeArrangement = true

        containerStackView.addArrangedSubview(containerView)

        let title = MultilineLabel(value: String(key: .REFERRAL_PROGRESS_MORE_INFO_HEADLINE), style: .draggableOverlayTitle)
        bag += containerView.addArranged(title)

        let body = MarkdownText(textSignal: .static(String(key: .REFERRAL_PROGRESS_MORE_INFO_PARAGRAPH(referralValue: "10"))), style: .bodyOffBlack)
        bag += containerView.addArranged(body)

        let button = Button(title: String(key: .REFERRAL_PROGRESS_MORE_INFO_CTA), type: .pillSemiTransparent(backgroundColor: .hedvig(.lightGray), textColor: .hedvig(.offBlack)))
        bag += containerView.addArranged(button.wrappedIn(UIStackView())) { stackView in
            stackView.alignment = .center
            stackView.axis = .vertical
        }

        bag += button.onTapSignal.onValue { _ in
            guard let url = URL(string: String(key: .REFERRAL_MORE_INFO_LINK)) else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }

        bag += containerStackView.applyPreferredContentSize(on: viewController)

        viewController.view = containerStackView

        return (viewController, Future { _ in
            bag
        })
    }
}
