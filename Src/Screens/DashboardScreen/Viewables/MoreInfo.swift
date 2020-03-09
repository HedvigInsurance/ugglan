//
//  MoreInfo.swift
//  ugglan
//
//  Created by Axel Backlund on 2019-04-10.
//

import Apollo
import Flow
import Form
import Foundation
import UIKit
import Common
import Space

struct MoreInfo {
    @Inject private var client: ApolloClient
}

extension MoreInfo: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let contentEdgeInsets: CGFloat = 20

        let contentViewInsets = UIEdgeInsets(
            top: 20,
            left: contentEdgeInsets,
            bottom: 20,
            right: contentEdgeInsets
        )

        let moreInfoStackView = UIStackView()
        moreInfoStackView.spacing = 6
        moreInfoStackView.axis = .vertical
        moreInfoStackView.edgeInsets = contentViewInsets

        bag += client.watch(query: DashboardQuery()).compactMap { $0.data?.insurance.type }.onValueDisposePrevious { type in
            let innerBag = DisposeBag()

            if type.isApartment {
                let deductibleCheckmark = MultilineLabelIcon(
                    styledText: StyledText(
                        text: String(key: .DASHBOARD_INFO_DEDUCTIBLE),
                        style: .bodyOffBlack
                    ),
                    icon: Asset.greenCircularCheckmark,
                    iconWidth: 15
                )
                innerBag += moreInfoStackView.addArranged(deductibleCheckmark)

                if type.isStudent {
                    let totalAmountCheckmark = MultilineLabelIcon(
                        styledText: StyledText(
                            text: String(key: .DASHBOARD_INFO_INSURANCE_STUFF_AMOUNT(maxCompensation: Localization.Key.MAX_COMPENSATION_STUDENT)),
                            style: .bodyOffBlack
                        ),
                        icon: Asset.greenCircularCheckmark,
                        iconWidth: 15
                    )
                    innerBag += moreInfoStackView.addArranged(totalAmountCheckmark)
                } else {
                    let totalAmountCheckmark = MultilineLabelIcon(
                        styledText: StyledText(
                            text: String(key: .DASHBOARD_INFO_INSURANCE_STUFF_AMOUNT(maxCompensation: Localization.Key.MAX_COMPENSATION)),
                            style: .bodyOffBlack
                        ),
                        icon: Asset.greenCircularCheckmark,
                        iconWidth: 15
                    )
                    innerBag += moreInfoStackView.addArranged(totalAmountCheckmark)
                }
            } else {
                let insuredValueCheckmark = MultilineLabelIcon(
                    styledText: StyledText(
                        text: String(key: .DASHBOARD_INFO_HOUSE_VALUE),
                        style: .bodyOffBlack
                    ),
                    icon: Asset.greenCircularCheckmark,
                    iconWidth: 15
                )
                innerBag += moreInfoStackView.addArranged(insuredValueCheckmark)

                let deductibleCheckmark = MultilineLabelIcon(
                    styledText: StyledText(
                        text: String(key: .DASHBOARD_INFO_DEDUCTIBLE_HOUSE(
                            deductible: Localization.Key.DEDUCTIBLE
                        )
                        ),
                        style: .bodyOffBlack
                    ),
                    icon: Asset.greenCircularCheckmark,
                    iconWidth: 15
                )
                innerBag += moreInfoStackView.addArranged(deductibleCheckmark)
            }

            let travelValidCheckmark = MultilineLabelIcon(
                styledText: StyledText(
                    text: String(key: .DASHBOARD_INFO_TRAVEL),
                    style: .bodyOffBlack
                ),
                icon: Asset.greenCircularCheckmark,
                iconWidth: 15
            )
            innerBag += moreInfoStackView.addArranged(travelValidCheckmark)

            return innerBag
        }

        return (moreInfoStackView, bag)
    }
}
