//
//  OfferTermsBulletpoints.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-08-20.
//

import Apollo
import Flow
import Form
import Foundation
import UIKit

struct OfferTermsBulletPoints {
    @Inject var client: ApolloClient

    init() {}
}

extension OfferTermsBulletPoints {
    struct BulletPoint: Viewable {
        let title: String

        func materialize(events _: ViewableEvents) -> (UIStackView, Disposable) {
            let bag = DisposeBag()
            let stackView = UIStackView()
            stackView.spacing = 15

            let checkMark = Icon(icon: Asset.greenCircularCheckmark, iconWidth: 20)
            stackView.addArrangedSubview(checkMark)

            checkMark.snp.makeConstraints { make in
                make.width.equalTo(20)
            }

            let label = MultilineLabel(value: title, style: .rowSubtitle)
            bag += stackView.addArranged(label)

            return (stackView, bag)
        }
    }
}

extension OfferTermsBulletPoints: Viewable {
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

        bag += client
            .fetch(query: OfferQuery())
            .valueSignal
            .compactMap { $0.data?.insurance.type }
            .onValueDisposePrevious { insuranceType in
                let innerBag = DisposeBag()

                innerBag += stackView.addArranged(BulletPoint(title: String(key: .OFFER_TERMS_NO_BINDING_PERIOD)))

                if insuranceType.isOwnedApartment {
                    innerBag += stackView.addArranged(BulletPoint(title: String(key: .OFFER_TERMS_NO_COVERAGE_LIMIT)))
                }

                if insuranceType.isStudent {
                    innerBag += stackView.addArranged(
                        BulletPoint(
                            title: String(
                                key: .OFFER_TERMS_MAX_COMPENSATION(
                                    maxCompensation: Localization.Key.MAX_COMPENSATION_STUDENT
                                )
                            )
                        )
                    )
                } else {
                    innerBag += stackView.addArranged(
                        BulletPoint(
                            title: String(
                                key: .OFFER_TERMS_MAX_COMPENSATION(
                                    maxCompensation: Localization.Key.MAX_COMPENSATION
                                )
                            )
                        )
                    )
                }

                innerBag += stackView.addArranged(
                    BulletPoint(
                        title: String(key: .OFFER_TERMS_DEDUCTIBLE(deductible: Localization.Key.DEDUCTIBLE))
                    )
                )

                return innerBag
            }

        return (stackView, bag)
    }
}
