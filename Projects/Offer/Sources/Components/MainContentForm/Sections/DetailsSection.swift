//
//  DetailsSection.swift
//  Offer
//
//  Created by Sam Pettersson on 2021-04-21.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

struct DetailsSection {
	@Inject var state: OfferState
}

extension DetailsSection: Presentable {
	func materialize() -> (UIView, Disposable) {
		let section = SectionView(headerView: nil, footerView: nil)
		section.dynamicStyle = .brandGrouped(separatorType: .none)
		let bag = DisposeBag()

		bag += state.quotesSignal.onValueDisposePrevious { quotes in
			quotes.enumerated()
				.map { (offset, quote) -> DisposeBag in
					let innerBag = DisposeBag()

					let headerContainer = UIStackView()
					headerContainer.edgeInsets = UIEdgeInsets(
						top: offset == 0 ? 0 : 15,
						left: 0,
						bottom: 0,
						right: 0
					)
					headerContainer.addArrangedSubview(
						UILabel(
							value: quote.detailsTable.title,
							style: .brand(.title2(color: .primary))
						)
					)

					let innerSection = SectionView(headerView: headerContainer, footerView: nil)
					section.append(innerSection)

					innerBag += {
						innerSection.removeFromSuperview()
					}

					quote.detailsTable.sections.enumerated()
						.forEach { (offset, section) in
							let headerContainer = UIStackView()
							headerContainer.edgeInsets = UIEdgeInsets(
								top: offset == 0 ? 0 : 15,
								left: 0,
								bottom: 0,
								right: 0
							)
							headerContainer.addArrangedSubview(
								UILabel(
									value: section.title,
									style: .brand(.callout(color: .tertiary))
								)
							)

							let detailsSection = SectionView(
								headerView: headerContainer,
								footerView: nil
							)
							innerSection.append(detailsSection)

							section.rows.forEach { tableRow in
								let row = RowView(
									title: tableRow.title,
									subtitle: tableRow.subtitle ?? ""
								)
								detailsSection.append(row)

								let valueLabel = UILabel(
									value: tableRow.value,
									style: .brand(.body(color: .secondary))
								)
								row.append(valueLabel)
							}
						}

					return innerBag
				}
				.disposable
		}

		let expandableView = ExpandableContent(
			contentView: section,
			isExpanded: .init(false),
			collapsedMaxHeight: 400
		)
		.materialize(into: bag)

		return (expandableView, bag)
	}
}
