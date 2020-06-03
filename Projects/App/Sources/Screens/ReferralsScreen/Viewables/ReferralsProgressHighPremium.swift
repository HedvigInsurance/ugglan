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
import hCore
import hCoreUI
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
        backgroundView.backgroundColor = .black
        backgroundView.layer.cornerRadius = 10

        let contentView = UIStackView()
        contentView.isLayoutMarginsRelativeArrangement = true
        contentView.layoutMargins = UIEdgeInsets(horizontalInset: 24, verticalInset: 24)
        contentView.axis = .vertical
        contentView.spacing = 5

        let discountAmountTextStyle = TextStyle.standaloneLargeTitle.resized(to: 48).colored(.white)
        let discountAmountLabel = MultilineLabel(value: "", style: discountAmountTextStyle)
        bag += contentView.addArranged(discountAmountLabel)

        let informationLabel = MultilineLabel(value: L10n.referralProgressHighPremiumDiscountSubtitle, style: TextStyle.blockRowTitle.colored(.white))
        bag += contentView.addArranged(informationLabel)

        let netPremiumLabel = MultilineLabel(value: "", style: TextStyle.blockRowDescription.colored(.white))
        bag += contentView.addArranged(netPremiumLabel)

        bag += combineLatest(grossPremiumSignal.atOnce().compactMap { $0 }, netPremiumSignal.atOnce().compactMap { $0 }).onValue { grossPremium, netPremium in
            netPremiumLabel.styledTextSignal.value = StyledText(
                text: L10n.referralProgressHighPremiumDescription(netPremium),
                style: TextStyle.blockRowDescription.colored(.white)
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
