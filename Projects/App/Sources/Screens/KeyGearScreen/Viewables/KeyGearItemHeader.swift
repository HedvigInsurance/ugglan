import Apollo
import Flow
import Form
import Foundation
import UIKit
import hCore
import hGraphQL

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

        stackView.addArrangedSubview(
            UILabel(value: L10n.keyGearItemViewDeductibleTitle, style: .brand(.body(color: .primary)))
        )

        let deductibleValueContainerContainer = UIStackView()
        deductibleValueContainerContainer.alignment = .leading
        deductibleValueContainerContainer.axis = .vertical
        stackView.addArrangedSubview(deductibleValueContainerContainer)

        let deductibleValueContainer = UIStackView()
        deductibleValueContainerContainer.addArrangedSubview(deductibleValueContainer)

        let deductibleLabel = UILabel(value: "", style: .brand(.headline(color: .primary)))

        deductibleValueContainer.addArrangedSubview(deductibleLabel)
        deductibleValueContainer.addArrangedSubview(
            UILabel(value: " kr", style: .brand(.body(color: .secondary)))
        )

        bag += client.watch(query: GraphQL.KeyGearItemQuery(id: itemId))
            .map { $0.keyGearItem?.deductible.fragments.monetaryAmountFragment.amount }
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

        stackView.addArrangedSubview(
            UILabel(value: L10n.keyGearItemViewValuationTitle, style: .brand(.body(color: .primary)))
        )

        let emptyValuationLabel = UILabel(
            value: L10n.keyGearItemViewValuationEmpty,
            style: .brand(.body(color: .link))
        )
        emptyValuationLabel.isHidden = true
        stackView.addArrangedSubview(emptyValuationLabel)

        let valuationValueContainer = UIStackView()
        valuationValueContainer.axis = .vertical
        valuationValueContainer.spacing = 2.5

        let valuationValueLabel = UILabel(value: "", style: .brand(.headline(color: .primary)))
        valuationValueContainer.addArrangedSubview(valuationValueLabel)

        let valuationValueDescription = UILabel(value: "", style: .brand(.body(color: .link)))
        valuationValueDescription.adjustsFontSizeToFitWidth = true
        valuationValueContainer.addArrangedSubview(valuationValueDescription)

        stackView.addArrangedSubview(valuationValueContainer)

        row.append(stackView)

        let dataSignal = client.watch(query: GraphQL.KeyGearItemQuery(id: itemId))

        bag += dataSignal.map { $0.keyGearItem?.valuation }
            .animated(
                style: SpringAnimationStyle.lightBounce(),
                animations: { valuation in
                    if valuation == nil {
                        emptyValuationLabel.animationSafeIsHidden = false
                        valuationValueContainer.animationSafeIsHidden = true
                        valuationValueContainer.layoutIfNeeded()
                        emptyValuationLabel.layoutIfNeeded()
                    } else {
                        valuationValueContainer.animationSafeIsHidden = false
                        emptyValuationLabel.animationSafeIsHidden = true
                        valuationValueContainer.layoutIfNeeded()
                        emptyValuationLabel.layoutIfNeeded()

                        if let fixedValuation = valuation?.asKeyGearItemValuationFixed {
                            valuationValueLabel.value = "\(fixedValuation.ratio)%"
                            valuationValueDescription.value =
                                L10n.keyGearItemViewValuationPercentageLabel
                        } else if let marketValuation = valuation?
                            .asKeyGearItemValuationMarketValue
                        {
                            valuationValueLabel.value = "\(marketValuation.ratio)%"
                            valuationValueDescription.value =
                                L10n.keyGearItemViewValuationMarketDescription
                        }
                    }
                }
            )

        bag += events.onSelect.withLatestFrom(dataSignal).compactMap { _, data in data.keyGearItem }
            .onValue { item in

                if item.valuation != nil {
                    self.presentingViewController.present(
                        KeyGearValuation(itemId: self.itemId).wrappedInCloseButton(),
                        style: .modal,
                        options: [.defaults, .allowSwipeDismissAlways]
                    )
                } else {
                    self.presentingViewController.present(
                        KeyGearAddValuation(id: self.itemId, category: item.category)
                            .wrappedInCloseButton(),
                        style: .modal,
                        options: [.defaults, .allowSwipeDismissAlways]
                    )
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

        bag += valuationBox.append(
            ValuationBox(presentingViewController: presentingViewController, itemId: itemId)
        )

        stackView.addArrangedSubview(valuationBox)

        let deductibleBox = SectionView()

        bag += deductibleBox.append(DeductibleBox(itemId: itemId))

        stackView.addArrangedSubview(deductibleBox)

        return (stackView, bag)
    }
}
