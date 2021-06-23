import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct CurrentInsurerSection {
	let quoteBundle: GraphQL.QuoteBundleQuery.Data.QuoteBundle
}

extension CurrentInsurerSection: Presentable {
	func materialize() -> (UIView, Disposable) {
		let bag = DisposeBag()

		let sectionContainer = UIStackView()
		sectionContainer.axis = .vertical

		bag += sectionContainer.addArranged(Spacing(height: 16))

		bag += {
			for view in sectionContainer.subviews {
				view.removeFromSuperview()
			}
		}

		let cardContainer = UIStackView()
		cardContainer.edgeInsets = UIEdgeInsets(horizontalInset: 15, verticalInset: 5)
		var cardTitle = ""
		var cardBody = ""

		let inception = quoteBundle.inception
		if let concurrentInception = inception.asConcurrentInception {
			let section = SectionView(
				headerView: UILabel(value: "Your current insurance", style: .default),
				footerView: nil
			)
			sectionContainer.addArrangedSubview(section)

			let row = RowView(title: "Current insurer")
			section.append(row)

			let currentInsurerName = concurrentInception.currentInsurer?.displayName ?? ""

			row.append(
				UILabel(
					value: currentInsurerName,
					style: .brand(.body(color: .secondary))
				)
			)

			cardTitle = "Switching from \(currentInsurerName)"
			cardBody =
				"It only takes a minute with BankID and your new insurance with Hedvig is activated the same day as your old one from \(currentInsurerName) expires."

		} else if let independentInceptions = inception.asIndependentInceptions {
			let inceptions = independentInceptions.inceptions
			let headerText = inceptions.count > 1 ? "Your current insurances" : "Your current insurance"

			let section = SectionView(
				headerView: UILabel(value: headerText, style: .default),
				footerView: nil
			)
			sectionContainer.addArrangedSubview(section)

			bag +=
				inceptions
				.map { ($0.currentInsurer, $0.correspondingQuote.asCompleteQuote?.id) }
				.filter { $0.0 != nil }
				.map { currentInsurer, correspondingQuoteID in
					let innerBag = DisposeBag()

					let insuranceType = quoteBundle.quoteFor(id: correspondingQuoteID)?.displayName
					let rowViewTitle = inceptions.count == 1 ? "Current insurer" : insuranceType

					let row = RowView(title: rowViewTitle ?? "")
					section.append(row)

					row.append(
						UILabel(
							value: currentInsurer?.displayName ?? "",
							style: .brand(.body(color: .secondary))
						)
					)

					return innerBag
				}

			cardTitle =
				inceptions.count == 1
				? "Switching from \(inceptions[0].currentInsurer?.displayName ?? "")"
				: "Switching to Hedvig"
			cardBody =
				inceptions.count == 1
				? "It only takes a minute with BankID and your new insurance with Hedvig is activated the same day as your old one from \(inceptions[0].currentInsurer?.displayName ?? "") expires."
				: "It only takes a minute with BankID and your new insurance with Hedvig is activated the same day as your old ones expire."
		}

		let switchingCard = Card(
			titleIcon: hCoreUIAssets.apartment.image,
			title: cardTitle,
			body: cardBody,
			backgroundColor: .tint(.lavenderTwo)
		)

		sectionContainer.addArrangedSubview(cardContainer)
		bag += cardContainer.addArranged(switchingCard)

		return (sectionContainer, bag)
	}
}
