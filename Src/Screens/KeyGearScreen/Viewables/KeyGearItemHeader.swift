//
//  KeyGearItemHeader.swift
//  test
//
//  Created by Sam Pettersson on 2020-02-14.
//

import Apollo
import Flow
import Form
import Foundation
import UIKit

struct KeyGearItemHeader {
    let presentingViewController: UIViewController
    let itemId: String
}

struct DeductibleBox: Viewable {
    func materialize(events _: ViewableEvents) -> (RowView, Disposable) {
        let row = RowView()

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5

        stackView.addArrangedSubview(UILabel(value: String(key: .KEY_GEAR_ITEM_VIEW_DEDUCTIBLE_TITLE), style: .bodySmallSmallLeft))

        let deductibleValueContainerContainer = UIStackView()
        deductibleValueContainerContainer.alignment = .leading
        deductibleValueContainerContainer.axis = .vertical
        stackView.addArrangedSubview(deductibleValueContainerContainer)

        let deductibleValueContainer = UIStackView()
        deductibleValueContainerContainer.addArrangedSubview(deductibleValueContainer)

        deductibleValueContainer.addArrangedSubview(UILabel(value: String(key: .KEY_GEAR_ITEM_VIEW_DEDUCTIBLE_VALUE), style: .headlineLargeLargeLeft))
        deductibleValueContainer.addArrangedSubview(UILabel(value: " kr", style: .bodySmallSmallLeft))

        row.append(stackView)

        return (row, NilDisposer())
    }
}

struct ValuationBox: Viewable {
    let presentingViewController: UIViewController
    let itemId: String
    @Inject var client: ApolloClient

    func materialize(events: SelectableViewableEvents) -> (RowView, Disposable) {
        let bag = DisposeBag()
        let row = RowView()

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5

        stackView.addArrangedSubview(UILabel(value: String(key: .KEY_GEAR_ITEM_VIEW_VALUATION_TITLE), style: .bodySmallSmallLeft))
        stackView.addArrangedSubview(UILabel(value: String(key: .KEY_GEAR_ITEM_VIEW_VALUATION_EMPTY), style: .linksSmallSmallRight))

        row.append(stackView)

        let dataSignal = client.fetch(query: KeyGearItemQuery(id: itemId, languageCode: Localization.Locale.currentLocale.code)).valueSignal

        bag += events.onSelect.withLatestFrom(dataSignal.plain()).onValue { a in

            self.presentingViewController.present(KeyGearAddValuation(id: self.itemId, category: a.1.data!.keyGearItem!.category), style: .modal, options: [
                .defaults, .allowSwipeDismissAlways,
            ])
        }

        return (row, bag)
    }
}

extension KeyGearItemHeader: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let stackView = UIStackView()
        stackView.spacing = 10
        stackView.distribution = .fillEqually

        let valuationBox = SectionView()
        valuationBox.dynamicStyle = .sectionPlain

        bag += valuationBox.append(ValuationBox(presentingViewController: presentingViewController, itemId: itemId))

        stackView.addArrangedSubview(valuationBox)

        let deductibleBox = SectionView()
        deductibleBox.dynamicStyle = .sectionPlain

        bag += deductibleBox.append(DeductibleBox())

        stackView.addArrangedSubview(deductibleBox)

        return (stackView, bag)
    }
}
