//
//  KeyGearValuation.swift
//  test
//
//  Created by Sam Pettersson on 2020-02-17.
//

import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit

struct KeyGearValuation {
    let itemId: String
    @Inject var client: ApolloClient
}

extension KeyGearValuation: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let bag = DisposeBag()
        let viewController = UIViewController()
        viewController.title = String(key: .KEY_GEAR_ITEM_VIEW_VALUATION_PAGE_TITLE)
        viewController.navigationItem.hidesBackButton = true

        let form = FormView()
        bag += viewController.install(form)

        let headerStackView = UIStackView()
        headerStackView.axis = .vertical
        headerStackView.spacing = 8

        let totalPercentageLabel = UILabel(value: "", style: TextStyle.headlineLargeLargeCenter.resized(to: 48))
        headerStackView.addArrangedSubview(totalPercentageLabel)

        let totalPercentageDescriptionLabel = UILabel(value: "", style: .bodySmallSmallCenter)
        headerStackView.addArrangedSubview(totalPercentageDescriptionLabel)

        bag += form.append(Spacing(height: 30))

        form.append(headerStackView)

        bag += form.append(Spacing(height: 30))

        let descriptionLabel = MarkdownText(
            textSignal: .static(""),
            style: .bodySmallSmallCenter
        )
        bag += form.append(descriptionLabel)

        bag += client.watch(query: KeyGearItemQuery(id: itemId), cachePolicy: .returnCacheDataAndFetch).map { $0.data?.keyGearItem }.onValue { item in
            if let fixed = item?.valuation?.asKeyGearItemValuationFixed {
                descriptionLabel.textSignal.value = String(
                    key: .KEY_GEAR_ITEM_VIEW_VALUATION_BODY(
                        itemType: item?.category.name.localizedLowercase ?? "",
                        purchasePrice: item?.purchasePrice?.fragments.monetaryAmountFragment.formattedAmount ?? "",
                        valuationPercentage: fixed.ratio,
                        valuationPrice: fixed.valuation.fragments.monetaryAmountFragment.formattedAmount
                    )
                )

                totalPercentageLabel.value = "\(fixed.ratio)%"
                totalPercentageDescriptionLabel.value = String(key: .KEY_GEAR_ITEM_VIEW_VALUATION_PERCENTAGE_LABEL)
            } else if let marketValue = item?.valuation?.asKeyGearItemValuationMarketValue {
                descriptionLabel.textSignal.value = String(
                    key: .KEY_GEAR_ITEM_VIEW_VALUATION_MARKET_BODY(
                        itemType: item?.category.name.localizedLowercase ?? "",
                        valuationPercentage: marketValue.ratio
                    )
                )

                totalPercentageDescriptionLabel.value = String(key: .KEY_GEAR_ITEM_VIEW_VALUATION_MARKET_DESCRIPTION)
                totalPercentageLabel.value = "\(marketValue.ratio)%"
            }
        }

        return (viewController, Future { completion in
            let closeButton = CloseButton()

            bag += closeButton.onTapSignal.onValue { _ in
                completion(.success)
            }

            let item = UIBarButtonItem(viewable: closeButton)
            viewController.navigationItem.rightBarButtonItem = item

            return DelayedDisposer(bag, delay: 2.0)
        })
    }
}
