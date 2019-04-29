//
//  ReferralsOffer.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-03-18.
//

import Flow
import Form
import Foundation
import UIKit

struct ReferralsOffer {
    enum Mode {
        case receiver, sender

        func titleText() -> String {
            switch self {
            case .receiver:
                return String(key: .REFERRALS_OFFER_RECEIVER_TITLE)
            case .sender:
                return String(key: .REFERRALS_OFFER_SENDER_TITLE)
            }
        }

        func labelText(incentive: Int) -> String {
            switch self {
            case .receiver:
                return String(key: .REFERRALS_OFFER_RECEIVER_VALUE(incentive: String(incentive)))
            case .sender:
                return String(key: .REFERRALS_OFFER_SENDER_VALUE(incentive: String(incentive)))
            }
        }
    }

    let mode: Mode
    let incentive: Int

    init(
        mode: Mode,
        incentive: Int = RemoteConfigContainer.shared.referralsIncentive()
    ) {
        self.mode = mode
        self.incentive = incentive
    }
}

extension ReferralsOffer: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let containerView = UIStackView()
        containerView.axis = .vertical
        containerView.edgeInsets = UIEdgeInsets(
            top: 0,
            left: 20,
            bottom: 0,
            right: 20
        )
        containerView.isLayoutMarginsRelativeArrangement = true

        let title = UILabel(value: mode.titleText(), style: .boldSmallTitle)
        containerView.addArrangedSubview(title)
        
        let checkmarkView = MultilineLabelIcon(
            styledText: StyledText(
                text: mode.labelText(incentive: incentive),
                style: .bodyOffBlack
            ),
            icon: Asset.greenCircularCheckmark,
            iconWidth: 15
        )
        
        let bag = DisposeBag()
        
        bag += containerView.addArranged(checkmarkView)

        return (containerView, bag)
    }
}
