//
//  ReferralsProgressHighPremium.swift
//  hedvig
//
//  Created by Sam Pettersson on 2019-06-27.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import UIKit

struct ReferralsProgressHighPremium {
    let grossPremiumSignal: ReadSignal<Int?>
    let netPremiumSignal: ReadSignal<Int?>
}

extension ReferralsProgressHighPremium: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let view = UIStackView()
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 10, right: 16)

        let backgroundView = UIView()
        backgroundView.backgroundColor = .turquoise
        backgroundView.layer.cornerRadius = 10

        let contentView = UIStackView()
        contentView.isLayoutMarginsRelativeArrangement = true
        contentView.layoutMargins = UIEdgeInsets(horizontalInset: 24, verticalInset: 24)
        contentView.axis = .vertical
        contentView.spacing = 5

        let discountAmountTextStyle = TextStyle.standaloneLargeTitle.resized(to: 48)
        let discountAmountLabel = MultilineLabel(value: "", style: discountAmountTextStyle)
        bag += contentView.addArranged(discountAmountLabel)

        let informationLabel = MultilineLabel(value: String(key: .REFERRAL_PROGRESS_HIGH_PREMIUM_DISCOUNT_SUBTITLE), style: .blockRowTitle)
        bag += contentView.addArranged(informationLabel)

        let netPremiumLabel = MultilineLabel(value: "", style: .blockRowDescription)
        bag += contentView.addArranged(netPremiumLabel)

        bag += combineLatest(grossPremiumSignal.atOnce().compactMap { $0 }, netPremiumSignal.atOnce().compactMap { $0 }).onValue { grossPremium, netPremium in
            netPremiumLabel.styledTextSignal.value = StyledText(
                text: String(key: .REFERRAL_PROGRESS_HIGH_PREMIUM_DESCRIPTION(monthlyCost: String(netPremium))),
                style: .blockRowDescription
            )
            let discount = grossPremium - netPremium
            discountAmountLabel.styledTextSignal.value = StyledText(text: discount > 0 ? "-\(discount) kr" : "\(discount) kr", style: discountAmountTextStyle)
        }

        backgroundView.addSubview(contentView)
        view.addArrangedSubview(backgroundView)

        contentView.snp.makeConstraints { make in
            make.trailing.leading.top.bottom.equalToSuperview()
        }

        return (view, bag)
    }
}
