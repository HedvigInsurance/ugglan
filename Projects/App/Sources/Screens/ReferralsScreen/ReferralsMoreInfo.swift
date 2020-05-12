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
import hCoreUI

struct ReferralsMoreInfo {}

extension ReferralsMoreInfo: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let bag = DisposeBag()

        let viewController = UIViewController()

        let containerStackView = UIStackView()
        bag += containerStackView.applySafeAreaBottomLayoutMargin()

        let containerView = UIStackView()
        containerView.spacing = 15
        containerView.backgroundColor = UIColor.white
        containerView.axis = .vertical
        containerView.layoutMargins = UIEdgeInsets(horizontalInset: 15, verticalInset: 24)
        containerView.isLayoutMarginsRelativeArrangement = true

        containerStackView.addArrangedSubview(containerView)

        let title = MultilineLabel(value: L10n.referralProgressMoreInfoHeadline, style: .draggableOverlayTitle)
        bag += containerView.addArranged(title)

        let body = MarkdownText(textSignal: .static(L10n.referralProgressMoreInfoParagraph("10")), style: .bodyOffBlack)
        bag += containerView.addArranged(body)

        let button = Button(title: L10n.referralProgressMoreInfoCta, type: .pillSemiTransparent(backgroundColor: .lightGray, textColor: .offBlack))
        bag += containerView.addArranged(button.wrappedIn(UIStackView())) { stackView in
            stackView.alignment = .center
            stackView.axis = .vertical
        }

        bag += button.onTapSignal.onValue { _ in
            guard let url = URL(string: L10n.referralMoreInfoLink) else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }

        bag += containerStackView.applyPreferredContentSize(on: viewController)

        viewController.view = containerStackView

        return (viewController, Future { _ in
            bag
        })
    }
}
