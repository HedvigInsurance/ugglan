import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct StartDateSection { @Inject var state: OfferState }

extension GraphQL.QuoteBundleQuery.Data.QuoteBundle {
	var canHaveIndependentStartDates: Bool {
		self.quotes.count > 1 && self.inception.asIndependentInceptions != nil
	}

	var switcher: Bool {
		self.inception.asConcurrentInception?.currentInsurer != nil
			|| self.inception.asIndependentInceptions?.inceptions
				.contains(where: { inception in
					inception.currentInsurer != nil
				}) == true
	}

	var fallbackDisplayValue: String {
		if switcher {
			return L10n.startDateExpires
		}

		return Date().localDateStringWithToday ?? ""
	}

	var displayableStartDate: String {
		if let concurrentInception = self.inception.asConcurrentInception {
			return concurrentInception.startDate?.localDateToDate?.localDateStringWithToday ?? ""
		}

		guard let independentInceptions = self.inception.asIndependentInceptions?.inceptions else { return "" }

		let startDates = independentInceptions.map { $0.startDate }
		let allStartDatesEqual = startDates.dropFirst().allSatisfy({ $0 == startDates.first })
		let dateDisplayValue =
			startDates.first??.localDateToDate?.localDateStringWithToday ?? fallbackDisplayValue

		return allStartDatesEqual ? dateDisplayValue : L10n.offerStartDateMultiple
	}
}

extension StartDateSection: Presentable {
	func materialize() -> (SectionView, Disposable) {
		let section = SectionView()
		section.dynamicStyle = .brandGroupedInset(
			separatorType: .none,
			border: .init(
				width: 1,
				color: .brand(.primaryBorderColor),
				cornerRadius: .defaultCornerRadius,
				borderEdges: .all
			),
			appliesShadow: false
		)

		let bag = DisposeBag()

		bag += state.dataSignal.map { $0.quoteBundle }
			.onValueDisposePrevious { quoteBundle in
				let innerBag = DisposeBag()

				let displayableStartDate = quoteBundle.displayableStartDate

				let row = RowView(
					title: quoteBundle.canHaveIndependentStartDates
						? L10n.offerStartDatePlural : L10n.offerStartDate
				)
				row.titleLabel?.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
				let iconImageView = UIImageView()
				iconImageView.image = hCoreUIAssets.calendar.image
				row.prepend(iconImageView)
				row.setCustomSpacing(17, after: iconImageView)

				let dateStyledText = StyledText(
					text: displayableStartDate,
					style: .brand(.body(color: .secondary))
				)

				let dateLabel = UILabel(
					styledText: dateStyledText
				)
				dateLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
				row.append(dateLabel)

				innerBag += dateLabel.didLayoutSignal.onValue {
					let rect = NSAttributedString(styledText: dateStyledText)
						.boundingRect(
							with: CGSize(width: CGFloat(Int.max), height: CGFloat(Int.max)),
							options: [.usesLineFragmentOrigin, .usesFontLeading],
							context: nil
						)

					if rect.width > dateLabel.frame.width {
						row.subtitle = displayableStartDate
						dateLabel.isHidden = true
					} else {
						dateLabel.isHidden = false
						row.subtitle = nil
					}
				}

				row.append(hCoreUIAssets.chevronRight.image)

				innerBag += section.append(row).compactMap { _ in row.viewController }
					.onValue { viewController in
						viewController.present(
							StartDate(quoteBundle: quoteBundle).wrappedInCloseButton()
						)
					}
				innerBag += { section.remove(row) }

				return innerBag
			}

		return (section, bag)
	}
}
