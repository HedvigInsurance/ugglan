//
//  KeyGearValuation.swift
//  test
//
//  Created by Sam Pettersson on 2020-02-17.
//

import Flow
import Form
import Foundation
import Presentation
import UIKit

struct KeyGearValuation {}

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

        let totalPercentageLabel = UILabel(value: "70%", style: TextStyle.headlineLargeLargeCenter.resized(to: 48))
        headerStackView.addArrangedSubview(totalPercentageLabel)

        let totalPercentageDescriptionLabel = UILabel(value: "av marknadsvärdet", style: .bodySmallSmallCenter)
        headerStackView.addArrangedSubview(totalPercentageDescriptionLabel)

        bag += form.append(Spacing(height: 30))

        form.append(headerStackView)

        bag += form.append(Spacing(height: 30))

        let descriptionLabel = MarkdownText(
            text: String(
                key: .KEY_GEAR_ITEM_VIEW_VALUATION_BODY(
                    itemType: "TODO",
                    purchasePrice: "TODO",
                    valuationPercentage: "TODO",
                    valuationPrice: "TODO"
                )
            ),
            style: .bodySmallSmallCenter
        )
        bag += form.append(descriptionLabel)

        return (viewController, Future { completion in
            let closeButton = CloseButton()

            bag += closeButton.onTapSignal.onValue { _ in
                completion(.success)
            }

            let item = UIBarButtonItem(viewable: closeButton)
            viewController.navigationItem.leftBarButtonItem = item

            return DelayedDisposer(bag, delay: 2.0)
        })
    }
}
