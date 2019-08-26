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

struct OfferReadyToSign {
    let containerScrollView: UIScrollView
}

extension OfferReadyToSign: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let view = UIView()
        view.backgroundColor = .darkPurple

        let bottomPadding: CGFloat = 80

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: bottomPadding, right: 20)
        stackView.isLayoutMarginsRelativeArrangement = true
        view.addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.trailing.leading.top.bottom.equalToSuperview()
        }

        let titleLabel = MultilineLabel(value: String(key: .OFFER_GET_HEDVIG_TITLE), style: TextStyle.standaloneLargeTitle.colored(.white).centerAligned)
        bag += stackView.addArranged(titleLabel)

        let descriptionLabel = MultilineLabel(value: String(key: .OFFER_GET_HEDVIG_BODY), style: TextStyle.bodyWhite.centerAligned)
        bag += stackView.addArranged(descriptionLabel)

        bag += containerScrollView.contentOffsetSignal.onValue({ point in
            let viewPoint = self.containerScrollView.convert(CGPoint.zero, from: view)
            let correctViewPointY = viewPoint.y - self.containerScrollView.frame.height + bottomPadding + 50

            if point.y > correctViewPointY {
                view.alpha = min((point.y - correctViewPointY) / 50, 1)
            } else {
                view.alpha = 0
            }
        })

        return (view, bag)
    }
}
