//
//  OfferReadyToSign.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-08-06.
//

import Flow
import Form
import Foundation
import UIKit
import ComponentKit

struct OfferReadyToSign {
    let containerScrollView: UIScrollView
}

extension OfferReadyToSign: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let view = UIView()
        view.backgroundColor = Offer.primaryAccentColor

        var bottomPadding: CGFloat {
            return containerScrollView.safeAreaInsets.bottom == 0 ? 100 : 80
        }

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.isLayoutMarginsRelativeArrangement = true
        view.addSubview(stackView)

        bag += stackView.didMoveToWindowSignal.onValue { _ in
            stackView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: bottomPadding, right: 20)
        }

        stackView.snp.makeConstraints { make in
            make.trailing.leading.top.bottom.equalToSuperview()
        }

        let titleLabel = MultilineLabel(value: String(key: .OFFER_GET_HEDVIG_TITLE), style: TextStyle.standaloneLargeTitle.colored(.white).centerAligned)
        bag += stackView.addArranged(titleLabel)

        let descriptionLabel = MultilineLabel(value: String(key: .OFFER_GET_HEDVIG_BODY), style: TextStyle.bodyWhite.centerAligned)
        bag += stackView.addArranged(descriptionLabel)

        bag += containerScrollView.contentOffsetSignal.onValue { point in
            let viewPoint = self.containerScrollView.convert(CGPoint.zero, from: view)

            let correctViewPointY = viewPoint.y - self.containerScrollView.frame.height + bottomPadding + 50

            if point.y > correctViewPointY {
                let offset: CGFloat = self.containerScrollView.safeAreaInsets.bottom == 0 ? 30 : 50
                view.alpha = min((point.y - correctViewPointY) / offset, 1)
            } else {
                view.alpha = 0
            }
        }

        return (view, bag)
    }
}
