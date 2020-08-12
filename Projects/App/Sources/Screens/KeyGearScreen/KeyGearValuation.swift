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
import hCore
import hCoreUI
import hGraphQL
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
        viewController.title = L10n.keyGearItemViewValuationPageTitle
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

        bag += client.watch(query: GraphQL.KeyGearItemQuery(id: itemId), cachePolicy: .returnCacheDataAndFetch).map { $0.data?.keyGearItem }.onValue { item in
            if let fixed = item?.valuation?.asKeyGearItemValuationFixed {
                descriptionLabel.textSignal.value = L10n.keyGearItemViewValuationBody(
                    item?.category.name.localizedLowercase ?? "",
                    fixed.ratio,
                    item?.purchasePrice?.fragments.monetaryAmountFragment.monetaryAmount.formattedAmount ?? "",
                    fixed.valuation.fragments.monetaryAmountFragment.monetaryAmount.formattedAmount
                )

                totalPercentageLabel.value = "\(fixed.ratio)%"
                totalPercentageDescriptionLabel.value = L10n.keyGearItemViewValuationPercentageLabel
            } else if let marketValue = item?.valuation?.asKeyGearItemValuationMarketValue {
                descriptionLabel.textSignal.value = L10n.keyGearItemViewValuationMarketBody(item?.category.name.localizedLowercase ?? "", marketValue.ratio)
                totalPercentageDescriptionLabel.value = L10n.keyGearItemViewValuationMarketDescription
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
