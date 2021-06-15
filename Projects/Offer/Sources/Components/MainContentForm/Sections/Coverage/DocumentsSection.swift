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
import SafariServices
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct DocumentsSection {
	let quote: GraphQL.QuoteBundleQuery.Data.QuoteBundle.Quote
}

extension DocumentsSection: Presentable {
	func materialize() -> (SectionView, Disposable) {
		let section = SectionView(
			headerView: UILabel(value: "Important documents", style: .default),
			footerView: nil
		)
		let rowContainer = UIStackView()
		rowContainer.edgeInsets = UIEdgeInsets(horizontalInset: 15, verticalInset: 5)
		section.append(rowContainer)
		rowContainer.axis = .vertical
		rowContainer.spacing = 8

		let bag = DisposeBag()

		bag += quote.insuranceTerms.map { term in
			let innerBag = DisposeBag()

			let rowControl = UIControl()
			rowControl.layer.cornerRadius = .defaultCornerRadius
			let backgroundColor = UIColor.brand(.secondaryBackground())
			rowControl.backgroundColor = backgroundColor

			bag += rowControl.applyShadow { _ in
				UIView.ShadowProperties(
					opacity: 1,
					offset: CGSize(width: 0, height: 1),
					blurRadius: nil,
					color: UIColor.black.withAlphaComponent(0.1),
					path: nil,
					radius: 2
				)
			}

			innerBag += rowControl.signal(for: .touchDown)
				.animated(
					style: .easeOut(duration: 0.25),
					animations: { _ in
						rowControl.backgroundColor = backgroundColor.darkened(amount: 0.05)
					}
				)

			innerBag += rowControl.delayedTouchCancel()
				.animated(
					style: .easeOut(duration: 0.25),
					animations: { _ in
						rowControl.backgroundColor = backgroundColor
					}
				)

			rowContainer.addArrangedSubview(rowControl)

			let rowContentContainer = UIStackView()
			rowContentContainer.isUserInteractionEnabled = false
			rowContentContainer.spacing = 8
			rowContentContainer.edgeInsets = UIEdgeInsets(inset: 17)
			rowControl.addSubview(rowContentContainer)

			rowContentContainer.snp.makeConstraints { make in
				make.edges.equalToSuperview()
			}

			rowContentContainer.addArrangedSubview(
				hCoreUIAssets.document.image.imageView(height: 34, width: 34)
			)

			let rowLabel = UILabel(value: term.displayName, style: .brand(.body(color: .primary)))
			rowContentContainer.addArrangedSubview(rowLabel)

			rowContentContainer.addArrangedSubview(hCoreUIAssets.external.image.imageView(width: 20))

			rowContainer.addArrangedSubview(rowControl)

			innerBag += rowControl.signal(for: .touchUpInside)
				.onValue { _ in
					guard let url = URL(string: term.url) else {
						return
					}
					let viewController = SFSafariViewController(url: url)
					viewController.modalPresentationStyle = .formSheet
					section.viewController?.present(viewController, animated: true)
				}

			return innerBag
		}

		return (section, bag)
	}
}
