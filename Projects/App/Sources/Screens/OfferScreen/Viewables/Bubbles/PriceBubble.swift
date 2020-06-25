//
//  PriceBubble.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-08-06.
//

import Ease
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import UIKit

struct PriceBubble {
    let dataSignal = ReadWriteSignal<OfferQuery.Data?>(nil)
}

extension PriceBubble: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let containerView = UIStackView()
        containerView.axis = .vertical
        containerView.alignment = .center

        let bubbleView = UIView()
        containerView.addArrangedSubview(bubbleView)

        let stackView = CenterAllStackView()
        stackView.axis = .vertical
        stackView.alignment = .center

        bubbleView.addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.trailing.leading.top.bottom.equalToSuperview()
        }

        let grossPriceLabel = UILabel(value: "", style: TextStyle.priceBubbleGrossTitle)
        grossPriceLabel.animationSafeIsHidden = true

        stackView.addArrangedSubview(grossPriceLabel)

        let priceLabel = UILabel(value: "", style: TextStyle.largePriceBubbleTitle)

        let ease: Ease<CGFloat> = Ease(0, minimumStep: 1)

        let grossPriceSignal = dataSignal
            .compactMap { $0?.insurance.cost?.fragments.costFragment.monthlyGross.amount }
            .toInt()
            .compactMap { $0 }
        
        let grossCurrencySignal = dataSignal
            .compactMap { $0?.insurance.cost?.fragments.costFragment.monthlyGross.currency }

        let discountSignal = dataSignal
            .compactMap { $0?.insurance.cost?.fragments.costFragment.monthlyDiscount.amount }
            .toInt()
            .compactMap { $0 }
            .readable(initial: 0)

        bag += combineLatest(discountSignal.plain(), grossPriceSignal, grossCurrencySignal)
            .animated(style: SpringAnimationStyle.mediumBounce(), animations: { monthlyDiscount, monthlyGross, grossCurrency in
                grossPriceLabel.styledText = StyledText(text: MonetaryAmount(amount: Float(monthlyGross), currency: grossCurrency).formattedAmount, style: TextStyle.priceBubbleGrossTitle)
                grossPriceLabel.animationSafeIsHidden = monthlyDiscount == 0
                grossPriceLabel.alpha = monthlyDiscount == 0 ? 0 : 1
            })

        let monthlyNetPriceSignal = dataSignal
            .compactMap { $0?.insurance.cost?.fragments.costFragment.monthlyNet.amount }
            .toInt()
            .compactMap { $0 }
            .buffer()

        bag += monthlyNetPriceSignal.onValue { values in
            guard let value = values.last else { return }

            if values.count == 1 {
                ease.value = CGFloat(value)
            }

            ease.targetValue = CGFloat(value)
        }

        bag += ease.addSpring(tension: 300, damping: 100, mass: 2) { number in
            if number != 0 {
                let textStyle = discountSignal.value > 0 ?
                    TextStyle.largePriceBubbleTitle.colored(.pink) :
                    TextStyle.largePriceBubbleTitle
                priceLabel.styledText = StyledText(
                    text: String(Int(number)),
                    style: textStyle
                )
            }
        }

        stackView.addArrangedSubview(priceLabel)

        bag += stackView.addArranged(MultilineLabel(
            value: L10n.offerPriceBubbleMonth,
            style: TextStyle.rowSubtitle.centerAligned
        ))

        let campaignTypeSignal = dataSignal.map { $0?.redeemedCampaigns.first }.map { campaign -> CampaignBubble.CampaignType? in
            let incentiveFragment = campaign?.fragments.campaignFragment.incentive?.fragments.incentiveFragment

            if let freeMonths = incentiveFragment?.asFreeMonths {
                return CampaignBubble.CampaignType.freeMonths(number: freeMonths.quantity ?? 0)
            }

            if let percentageDiscount = incentiveFragment?.asPercentageDiscountMonths {
                return CampaignBubble.CampaignType.percentageDiscount(
                    value: percentageDiscount.percentageDiscount,
                    months: percentageDiscount.percentageNumberOfMonths
                )
            }

            if incentiveFragment?.asMonthlyCostDeduction != nil {
                return CampaignBubble.CampaignType.invited
            }

            return nil
        }

        let campaignBubble = CampaignBubble(campaignTypeSignal: campaignTypeSignal)
        bag += bubbleView.add(campaignBubble) { campaignBubbleView in
            campaignBubbleView.snp.makeConstraints { make in
                make.right.equalTo(120)
                make.top.equalTo(-10)
            }
        }

        bubbleView.transform = CGAffineTransform(scaleX: 0, y: 0).concatenating(CGAffineTransform(translationX: 0, y: -30))
        bubbleView.alpha = 0

        bag += dataSignal.toVoid().delay(by: 0.75)
            .animated(style: SpringAnimationStyle.mediumBounce()) { _ in
                bubbleView.alpha = 1
                bubbleView.transform = CGAffineTransform.identity
            }

        return (containerView, bag)
    }
}
