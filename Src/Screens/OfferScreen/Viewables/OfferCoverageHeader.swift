//
//  OfferCoverageHeader.swift
//  project
//
//  Created by Sam Pettersson on 2019-08-05.
//

import Flow
import Form
import Foundation
import UIKit
import ComponentKit

struct OfferCoverageHeader {}

extension OfferCoverageHeader: Viewable {
    func materialize(events _: ViewableEvents) -> (UIStackView, Disposable) {
        let stackView = UIStackView()
        stackView.axis = .vertical

        let bag = DisposeBag()

        bag += stackView.addArranged(Blob(color: .secondaryBackground, position: .top)) { view in
            bag += view.applyShadow { _ in
                UIView.ShadowProperties(
                    opacity: 0.1,
                    offset: CGSize(width: 0, height: 0),
                    radius: 20,
                    color: .primaryShadowColor,
                    path: nil
                )
            }
        }

        let labelContainer = UIView()
        stackView.addArrangedSubview(labelContainer)
        labelContainer.backgroundColor = .secondaryBackground

        let labelStackView = UIStackView()
        labelStackView.layoutMargins = UIEdgeInsets(horizontalInset: 0, verticalInset: 10)
        labelStackView.isLayoutMarginsRelativeArrangement = true
        labelContainer.addSubview(labelStackView)

        labelStackView.snp.makeConstraints { make in
            make.leading.trailing.bottom.top.equalToSuperview()
        }

        bag += labelStackView.addArranged(MultilineLabel(
            value: String(key: .OFFER_SCROLL_HEADER),
            style: TextStyle.standaloneLargeTitle.centerAligned
        ))

        return (stackView, bag)
    }
}
