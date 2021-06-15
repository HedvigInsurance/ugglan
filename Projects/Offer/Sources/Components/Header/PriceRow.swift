//
//  PriceRow.swift
//  Offer
//
//  Created by Sam Pettersson on 2021-04-19.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

struct PriceRow {
	@Inject var state: OfferState
}

extension PriceRow: Presentable {
	func materialize() -> (RowView, Disposable) {
		let row = RowView()
		let bag = DisposeBag()

		let view = UIStackView()
		view.axis = .vertical
		view.spacing = 5

		let priceContainer = UIStackView()
		priceContainer.axis = .vertical
		priceContainer.distribution = .equalCentering
		priceContainer.alignment = .center
		view.addArrangedSubview(priceContainer)

		let priceHorizontalContainer = UIStackView()
		priceHorizontalContainer.axis = .horizontal
		priceHorizontalContainer.distribution = .equalSpacing
		priceHorizontalContainer.alignment = .center
		priceHorizontalContainer.spacing = 2
		priceContainer.addArrangedSubview(priceHorizontalContainer)

		let grossPriceLabel = UILabel(
			value: "",
			style: TextStyle.brand(.callout(color: .tertiary)).centerAligned
				.restyled { (style: inout TextStyle) in
					style.setParagraphAttribute(
						2,
						for: NSAttributedString.Key.strikethroughStyle,
						update: { _ in }
					)
				}
		)
		priceHorizontalContainer.addArrangedSubview(grossPriceLabel)

		let netPriceLabel = UILabel(
			value: "",
			style: TextStyle.brand(.largeTitle(color: .primary)).centerAligned
		)
		priceHorizontalContainer.addArrangedSubview(netPriceLabel)

		let perMonthLabel = UILabel(
			value: "",
			style: TextStyle.brand(.subHeadline(color: .primary)).centerAligned
		)
		view.addArrangedSubview(perMonthLabel)

		bag += state.dataSignal.map { $0.quoteBundle.bundleCost }
			.onValue { bundleCost in
				grossPriceLabel.isHidden =
					bundleCost.monthlyDiscount.fragments.monetaryAmountFragment.monetaryAmount
					.floatAmount == 0
				netPriceLabel.value =
					bundleCost.monthlyNet.fragments.monetaryAmountFragment.monetaryAmount
					.formattedAmountWithoutSymbol
				grossPriceLabel.value =
					bundleCost.monthlyGross.fragments.monetaryAmountFragment.monetaryAmount
					.formattedAmountWithoutSymbol
				perMonthLabel.value =
					"\(bundleCost.monthlyNet.fragments.monetaryAmountFragment.monetaryAmount.currencySymbol)\(L10n.perMonth)"
			}

		row.append(view)

		return (row, bag)
	}
}
