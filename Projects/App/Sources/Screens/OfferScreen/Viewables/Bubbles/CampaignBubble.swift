//
//  CampaignBubble.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-08-19.
//

import Flow
import Form
import Foundation
import UIKit

struct CampaignBubble {
    let campaignTypeSignal: ReadSignal<CampaignType?>

    enum CampaignType {
        case freeMonths(number: Int), percentageDiscount(value: Double, months: Int), invited, monthlyDeduction(amount: String)
    }
}

extension CampaignBubble: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let containerView = UIView()
        containerView.backgroundColor = .pink

        bag += containerView.applyShadow { _ in
            OfferBubble.shadow
        }

        containerView.snp.makeConstraints { make in
            make.width.height.equalTo(100)
        }

        let view = UIStackView()
        view.axis = .vertical
        view.layoutMargins = UIEdgeInsets(horizontalInset: 10, verticalInset: 0)
        view.isLayoutMarginsRelativeArrangement = true
        view.spacing = 5
        containerView.addSubview(view)

        view.snp.makeConstraints { make in
            make.trailing.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        bag += containerView.didLayoutSignal.onValue { _ in
            containerView.layer.cornerRadius = view.frame.width / 2
        }

        let titleLabel = UILabel(value: "", style: TextStyle.body.centerAligned.colored(.white))
        view.addArrangedSubview(titleLabel)

        let subtitlelabel = UILabel(value: "", style: TextStyle.bodyBold.centerAligned.colored(.white))
        subtitlelabel.numberOfLines = 0

        bag += subtitlelabel.didLayoutSignal.onValue { _ in
            subtitlelabel.preferredMaxLayoutWidth = subtitlelabel.frame.size.width
        }

        view.addArrangedSubview(subtitlelabel)

        containerView.transform = CGAffineTransform(scaleX: 0, y: 0).concatenating(CGAffineTransform(translationX: 0, y: -30))
        containerView.alpha = 0

        bag += campaignTypeSignal.animated(style: SpringAnimationStyle.mediumBounce()) { value in
            if let value = value {
                containerView.alpha = 1
                containerView.transform = CGAffineTransform.identity

                switch value {
                case let .freeMonths(number):
                    titleLabel.text = L10n.offerScreenFreeMonthsBubbleTitle
                    titleLabel.animationSafeIsHidden = false
                    subtitlelabel.text = L10n.offerScreenFreeMonthsBubble(number)
                case let .percentageDiscount(value, months):
                    titleLabel.text = L10n.offerScreenPercentageDiscountBubbleTitle
                    titleLabel.animationSafeIsHidden = false
                    if months == 1 {
                        subtitlelabel.text = L10n.offerScreenPercentageDiscountBubbleTitleSingular(Int(value))
                    } else {
                        subtitlelabel.text = L10n.offerScreenPercentageDiscountBubbleTitlePlural(months, Int(value))
                    }
                case let .monthlyDeduction(amount):
                    titleLabel.text = L10n.offerScreenPercentageDiscountBubbleTitle
                    titleLabel.animationSafeIsHidden = false
                    subtitlelabel.text = "-\(amount)/mån"
                case .invited:
                    titleLabel.text = ""
                    titleLabel.animationSafeIsHidden = true
                    subtitlelabel.text = L10n.offerScreenInvitedBubble
                }
            } else {
                titleLabel.animationSafeIsHidden = true
                titleLabel.text = ""
                subtitlelabel.text = ""

                containerView.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001).concatenating(CGAffineTransform(translationX: 0, y: -30))
                containerView.alpha = 0
            }
        }

        return (containerView, bag)
    }
}
