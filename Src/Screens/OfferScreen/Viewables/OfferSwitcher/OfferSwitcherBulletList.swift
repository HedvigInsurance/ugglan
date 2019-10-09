//
//  OfferSwitcherBulletList.swift
//  project
//
//  Created by Sam Pettersson on 2019-08-21.
//

import Apollo
import Flow
import Form
import Foundation
import UIKit

struct OfferSwitcherBulletList {
    @Inject var client: ApolloClient
}

extension OfferSwitcherBulletList {
    struct BulletPoint: Viewable {
        let index: Int
        let text: String

        func materialize(events _: ViewableEvents) -> (UIStackView, Disposable) {
            let bag = DisposeBag()
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.spacing = 15
            stackView.alignment = .center

            let circle = UIView()
            circle.backgroundColor = .purple

            bag += circle.didLayoutSignal.onValue {
                circle.layer.cornerRadius = circle.frame.height / 2
            }

            stackView.addArrangedSubview(circle)

            circle.snp.makeConstraints { make in
                make.height.width.equalTo(30)
            }

            let circleLabel = UILabel(value: String(index), style: TextStyle.bodyWhite.centerAligned)
            circle.addSubview(circleLabel)

            circleLabel.snp.makeConstraints { make in
                make.height.width.centerX.equalToSuperview()
                make.centerY.equalToSuperview().offset(1)
            }

            let textLabel = MultilineLabel(value: text, style: .rowSubtitle)
            bag += stackView.addArranged(textLabel)

            return (stackView, bag)
        }
    }
}

extension OfferSwitcherBulletList: Viewable {
    func materialize(events _: ViewableEvents) -> (UIStackView, Disposable) {
        let bag = DisposeBag()
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15

        bag += stackView.didMoveToWindowSignal.take(first: 1).onValue {
            stackView.snp.makeConstraints { make in
                make.width.equalToSuperview().multipliedBy(0.8)
            }
        }

        bag += client.fetch(query: OfferQuery())
            .valueSignal
            .compactMap { $0.data?.insurance.previousInsurer }
            .onValueDisposePrevious({ previousInsurer -> Disposable? in
                let innerBag = DisposeBag()

                innerBag += stackView.addArranged(BulletPoint(index: 1, text: String(key: .SIGN_MOBILE_BANK_ID)))

                if previousInsurer.switchable {
                    innerBag += stackView.addArranged(BulletPoint(index: 2, text: String(key: .OFFER_SWITCH_COL_PARAGRAPH_ONE_APP)))
                } else {
                    innerBag += stackView.addArranged(BulletPoint(index: 2, text: String(key: .OFFER_NON_SWITCHABLE_PARAGRAPH_ONE_APP)))
                }

                innerBag += stackView.addArranged(BulletPoint(index: 3, text: String(key: .OFFER_SWITCH_COL_THREE_PARAGRAPH_APP)))

                return innerBag
            })

        return (stackView, bag)
    }
}
