//
//  DiscountTerms.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-06-14.
//

import Flow
import Form
import Foundation
import UIKit
import ComponentKit

struct DiscountTerms {}

extension DiscountTerms: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let view = UIControl()

        bag += view.signal(for: .touchUpInside).compactMap {
            URL(string: String(key: .REFERRALS_RECEIVER_TERMS_LINK))
        }.onValue { url in
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }

        let containerStackView = UIStackView()
        containerStackView.isLayoutMarginsRelativeArrangement = true
        containerStackView.layoutMargins = UIEdgeInsets(
            top: 20,
            left: 0,
            bottom: 0,
            right: 0
        )
        containerStackView.isUserInteractionEnabled = false
        view.addSubview(containerStackView)

        containerStackView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }

        let termsAndConditionsString = String(key: .REFERRAL_ADDCOUPON_TC_LINK)
        let textStyle = TextStyle.reallySmallTitle.centerAligned

        let termsLabelText = String(
            key: .REFERRAL_ADDCOUPON_TC(termsAndConditionsLink: termsAndConditionsString)
        ).attributedStringWithVariableStyles(
            [termsAndConditionsString: textStyle.colored(.primaryTintColor)],
            fallbackStyle: textStyle.colored(.decorText)
        )

        let label = UILabel()
        label.isUserInteractionEnabled = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.attributedText = termsLabelText

        bag += label.didLayoutSignal.onValue {
            label.preferredMaxLayoutWidth = label.frame.size.width
        }

        containerStackView.addArrangedSubview(label)

        return (view, bag)
    }
}
