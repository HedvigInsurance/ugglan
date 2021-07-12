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

		sectionContainer.appendSpacing(.inbetween)

		bag += {
			for view in sectionContainer.subviews {
				view.removeFromSuperview()
			}
		}

		let cardContainer = UIStackView()
		cardContainer.edgeInsets = UIEdgeInsets(horizontalInset: 15, verticalInset: 10)
		var cardTitle = ""
		var cardBody = ""
		var switchable = false

		let inception = quoteBundle.inception
		if let concurrentInception = inception.asConcurrentInception {
			#warning("Translation needed")
			let section = SectionView(
				headerView: UILabel(value: "Your current insurance", style: .default),
				footerView: nil
			)
			section.dynamicStyle = .brandGroupedInset(separatorType: .standard)
			sectionContainer.addArrangedSubview(section)

			#warning("Translation needed — same as on line 82")
			let row = RowView(title: "Current insurer")
			section.append(row)

			let currentInsurerName = concurrentInception.currentInsurer?.displayName ?? ""
			switchable = concurrentInception.currentInsurer?.switchable ?? false

			row.append(
				UILabel(
					value: currentInsurerName,
					style: .brand(.body(color: .secondary))
				)
			)

			#warning("Translations needed")
			cardTitle = "Switching from \(currentInsurerName)"
			cardBody =
				"It only takes a minute with BankID and your new insurance with Hedvig is activated the same day as your old one from \(currentInsurerName) expires."

		} else if let independentInceptions = inception.asIndependentInceptions {
			let inceptions = independentInceptions.inceptions
			switchable =
				inceptions.map { $0.currentInsurer?.switchable ?? false }.filter { $0 == true }.count
				> 0
			#warning("Translations needed")
			let headerText = inceptions.count > 1 ? "Your current insurances" : "Your current insurance"

			let section = SectionView(
				headerView: UILabel(value: headerText, style: .default),
				footerView: nil
			)
			section.dynamicStyle = .brandGroupedInset(separatorType: .standard)
			sectionContainer.addArrangedSubview(section)

			bag +=
				inceptions
				.map { ($0.currentInsurer, $0.correspondingQuote.asCompleteQuote?.id) }
				.filter { $0.0 != nil }
				.map { currentInsurer, correspondingQuoteID in
					let innerBag = DisposeBag()

					let insuranceType = quoteBundle.quoteFor(id: correspondingQuoteID)?.displayName
					#warning("Translations needed")
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

			if let firstInception = inceptions.first {
				#warning("Translations needed")
				cardTitle =
					inceptions.count == 1
					? "Switching from \(firstInception.currentInsurer?.displayName ?? "")"
					: "Switching to Hedvig"

				#warning("Translations needed")
				cardBody =
					inceptions.count == 1
					? "It only takes a minute with BankID and your new insurance with Hedvig is activated the same day as your old one from \(firstInception.currentInsurer?.displayName ?? "") expires."
					: "It only takes a minute with BankID and your new insurance with Hedvig is activated the same day as your old ones expire."
			}
		}

		if switchable {
			let switchingCard = Card(
				titleIcon: hCoreUIAssets.apartment.image,
				title: cardTitle,
				body: cardBody,
				backgroundColor: .tint(.lavenderTwo)
			)

			sectionContainer.addArrangedSubview(cardContainer)
			bag += cardContainer.addArranged(switchingCard)
		}

		return (sectionContainer, bag)
	}
}
