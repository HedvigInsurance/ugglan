//
//  PriceRow.swift
//  Offer
//
//  Created by Sam Pettersson on 2021-04-19.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import UIKit
import Form
import hCore
import hCoreUI
import Flow
import Presentation

struct DiscountTag {
    @Inject var state: OfferState
}

extension DiscountTag: Presentable {
    func materialize() -> (UIView, Disposable) {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = .tint(.lavenderOne)
        let bag = DisposeBag()
        
        let horizontalCenteringStackView = UIStackView()
        horizontalCenteringStackView.edgeInsets = UIEdgeInsets(inset: 10)
        horizontalCenteringStackView.axis = .vertical
        horizontalCenteringStackView.alignment = .center
        horizontalCenteringStackView.distribution = .equalCentering
        view.addSubview(horizontalCenteringStackView)
        
        horizontalCenteringStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let contentStackView = UIStackView()
        contentStackView.axis = .horizontal
        contentStackView.spacing = 2
        contentStackView.alignment = .center
        contentStackView.distribution = .equalCentering
        horizontalCenteringStackView.addArrangedSubview(contentStackView)
        
        let textStyle = TextStyle.brand(.caption1(color: .primary(state: .positive))).centerAligned.uppercased
        
        let titleLabel = UILabel(
            value: "",
            style: textStyle
        )
        contentStackView.addArrangedSubview(titleLabel)

        let subtitleLabel = UILabel(
            value: "",
            style: textStyle
        )
        contentStackView.addArrangedSubview(subtitleLabel)
        
        bag += state.dataSignal.map { $0.redeemedCampaigns.first }.onValue { campaign in
            guard let campaign = campaign else {
                view.isHidden = true
                return
            }
            
            view.isHidden = false
            
            let incentiveFragment = campaign.fragments.campaignFragment.incentive?.fragments.incentiveFragment

            if let freeMonths = incentiveFragment?.asFreeMonths {
                titleLabel.value = L10n.offerScreenFreeMonthsBubbleTitle
                titleLabel.animationSafeIsHidden = false
                subtitleLabel.value = L10n.offerScreenFreeMonthsBubble(freeMonths.quantity ?? 0)
            } else if let percentageDiscount = incentiveFragment?.asPercentageDiscountMonths {
                titleLabel.value = L10n.offerScreenPercentageDiscountBubbleTitle
                titleLabel.animationSafeIsHidden = false
                let months = percentageDiscount.percentageNumberOfMonths
                if months == 1 {
                    subtitleLabel.value = L10n.offerScreenPercentageDiscountBubbleTitleSingular(Int(percentageDiscount.percentageDiscount))
                } else {
                    subtitleLabel.value = L10n.offerScreenPercentageDiscountBubbleTitlePlural(Int(percentageDiscount.percentageDiscount), months)
                }
            } else if let monthlyDeduction = incentiveFragment?.asMonthlyCostDeduction {
                titleLabel.value = L10n.offerScreenPercentageDiscountBubbleTitle
                titleLabel.animationSafeIsHidden = false
                subtitleLabel.value = "-\(monthlyDeduction.amount?.fragments.monetaryAmountFragment.monetaryAmount.formattedAmount ?? "")\(L10n.perMonth)"
            } else if let indefiniteDiscount = incentiveFragment?.asIndefinitePercentageDiscount {
                titleLabel.value = L10n.offerScreenPercentageDiscountBubbleTitle
                subtitleLabel.value = "\(Int(indefiniteDiscount.percentageDiscount))%"
            } else {
                view.isHidden = true
            }
        }
                
        return (view, bag)
    }
}
