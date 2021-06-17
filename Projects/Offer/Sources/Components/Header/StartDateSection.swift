import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct StartDateSection {
	@Inject var state: OfferState
}

extension StartDateSection: Presentable {
	func materialize() -> (SectionView, Disposable) {
		let section = SectionView()
		section.dynamicStyle = .brandGrouped(
			separatorType: .custom(55),
			shouldRoundCorners: { _ in false }
		)
		let bag = DisposeBag()

		bag += state.dataSignal.map { $0.quoteBundle.quotes }
			.onValueDisposePrevious { quotes in
				quotes.map { quote -> DisposeBag in
					let row = RowView(
						title: "Start date",
						subtitle: quotes.count > 1 ? quote.displayName : ""
					)

					let iconImageView = UIImageView()
					iconImageView.image = hCoreUIAssets.calendar.image

					row.prepend(iconImageView)
					row.setCustomSpacing(17, after: iconImageView)

					let dateLabel = UILabel(value: "Today", style: .brand(.body(color: .secondary)))
					row.append(dateLabel)

					row.append(hCoreUIAssets.chevronRight.image)

					let innerBag = DisposeBag()

					innerBag += section.append(row)
						.onValue { _ in
							// todo
						}

					innerBag += {
						section.remove(row)
					}

					return innerBag
				}
				.disposable
			}

		return (section, bag)
	}
}
