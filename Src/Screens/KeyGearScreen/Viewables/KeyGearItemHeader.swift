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
    let itemId: String
    @Inject var client: ApolloClient

    func materialize(events _: ViewableEvents) -> (RowView, Disposable) {
        let bag = DisposeBag()
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

        let deductibleLabel = UILabel(value: "", style: .headlineLargeLargeLeft)

        deductibleValueContainer.addArrangedSubview(deductibleLabel)
        deductibleValueContainer.addArrangedSubview(UILabel(value: " kr", style: .bodySmallSmallLeft))

        bag += client.watch(query: KeyGearItemQuery(id: itemId))
            .map { $0.data?.keyGearItem?.deductible.fragments.monetaryAmountFragment.amount }
            .bindTo(deductibleLabel, \.text)

        row.append(stackView)

        return (row, bag)
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

        let emptyValuationLabel = UILabel(value: String(key: .KEY_GEAR_ITEM_VIEW_VALUATION_EMPTY), style: .linksSmallSmallRight)
        emptyValuationLabel.isHidden = true
        stackView.addArrangedSubview(emptyValuationLabel)
        
        let valuationValueContainer = UIStackView()
        valuationValueContainer.axis = .vertical
        valuationValueContainer.spacing = 2.5
        
        let valuationValueLabel = UILabel(value: "", style: .headlineLargeLargeLeft)
        valuationValueContainer.addArrangedSubview(valuationValueLabel)
        
        let valuationValueDescription = UILabel(value: "", style: .linksSmallSmallRight)
        valuationValueDescription.adjustsFontSizeToFitWidth = true
        valuationValueContainer.addArrangedSubview(valuationValueDescription)
        
        stackView.addArrangedSubview(valuationValueContainer)

        row.append(stackView)

        let dataSignal = client.watch(query: KeyGearItemQuery(id: itemId))

        bag += dataSignal.map { $0.data?.keyGearItem?.valuation }.animated(style: SpringAnimationStyle.lightBounce(), animations: { valuation in
            if valuation == nil {
                emptyValuationLabel.isHidden = false
                valuationValueContainer.isHidden = true
                valuationValueContainer.layoutIfNeeded()
                emptyValuationLabel.layoutIfNeeded()
            } else {
                valuationValueContainer.isHidden = false
                emptyValuationLabel.isHidden = true
                valuationValueContainer.layoutIfNeeded()
                emptyValuationLabel.layoutIfNeeded()
                
                if let fixedValuation = valuation?.asKeyGearItemValuationFixed {
                    valuationValueLabel.value = "\(fixedValuation.ratio)%"
                    valuationValueDescription.value = String(key: .KEY_GEAR_ITEM_VIEW_VALUATION_PERCENTAGE_LABEL)
                } else if let marketValuation = valuation?.asKeyGearItemValuationMarketValue {
                    valuationValueLabel.value = "\(marketValuation.ratio)%"
                    valuationValueDescription.value = String(key: .KEY_GEAR_ITEM_VIEW_VALUATION_MARKET_DESCRIPTION)
                }
            }
        })

        bag += events.onSelect.withLatestFrom(dataSignal).compactMap { _, result in result.data?.keyGearItem }.onValue { item in
            
            if item.valuation != nil {
                self.presentingViewController.present(KeyGearValuation(itemId: self.itemId).withCloseButton, style: .modal, options: [
                    .defaults, .allowSwipeDismissAlways,
                ])
            } else {
                self.presentingViewController.present(KeyGearAddValuation(id: self.itemId, category: item.category).withCloseButton, style: .modal, options: [
                    .defaults, .allowSwipeDismissAlways,
                ])
            }
            
            
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

        bag += deductibleBox.append(DeductibleBox(itemId: itemId))

        stackView.addArrangedSubview(deductibleBox)

        return (stackView, bag)
    }
}
