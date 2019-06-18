
//
//  ApplyDiscount.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-06-12.
//

import Flow
import Form
import Foundation
import Presentation
import UIKit

struct ApplyDiscount {}

extension ApplyDiscount: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let viewController = UIViewController()

        let bag = DisposeBag()

        let containerView = UIStackView()
        bag += containerView.applySafeAreaBottomLayoutMargin()

        viewController.view = containerView

        let view = UIStackView()
        view.spacing = 5
        view.axis = .vertical
        view.layoutMargins = UIEdgeInsets(horizontalInset: 24, verticalInset: 32)
        view.isLayoutMarginsRelativeArrangement = true

        containerView.addArrangedSubview(view)

        let titleLabel = MultilineLabel(
            value: String(key: .REFERRAL_ADDCOUPON_HEADLINE),
            style: .standaloneLargeTitle
        )
        bag += view.addArranged(titleLabel)

        let descriptionLabel = MultilineLabel(
            value: String(key: .REFERRAL_ADDCOUPON_BODY),
            style: .bodyOffBlack
        )
        bag += view.addArranged(descriptionLabel)

        let textField = TextField(value: "", placeholder: String(key: .REFERRAL_ADDCOUPON_INPUTPLACEHOLDER))
        bag += view.addArranged(textField.wrappedIn(UIStackView())) { stackView in
            stackView.isLayoutMarginsRelativeArrangement = true
            stackView.layoutMargins = UIEdgeInsets(horizontalInset: 0, verticalInset: 20)
        }

        let submitButton = Button(
            title: String(key: .REFERRAL_ADDCOUPON_BTN_SUBMIT),
            type: .standard(backgroundColor: .purple, textColor: .white)
        )

        bag += view.addArranged(submitButton.wrappedIn(UIStackView())) { stackView in
            stackView.axis = .vertical
            stackView.alignment = .center
        }

        let terms = DiscountTerms()
        bag += view.addArranged(terms)

        bag += view.didLayoutSignal.map { _ in
            view.systemLayoutSizeFitting(CGSize.zero)
        }.onValue { size in
            view.snp.remakeConstraints { make in
                make.height.equalTo(size.height)
            }
        }

        bag += containerView.applyPreferredContentSize(on: viewController)

        return (viewController, Future { _ in
            bag
        })
    }
}
