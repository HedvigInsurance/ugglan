import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct MultiQuoteCoverage {
	let quotes: [GraphQL.QuoteBundleQuery.Data.QuoteBundle.Quote]
}

extension MultiQuoteCoverage: Presentable {
	func materialize() -> (SectionView, Disposable) {
		let section = SectionView(headerView: nil, footerView: nil)
		section.dynamicStyle = .brandGrouped(separatorType: .none)

		let bag = DisposeBag()

		bag += section.append(
			MultilineLabel(
				value:
					"Read the full coverage of your insurances below.",
				style: .brand(.body(color: .secondary))
			)
			.insetted(UIEdgeInsets(inset: 15))
		)

		bag += quotes.map { quote -> DisposeBag in
			let innerBag = DisposeBag()
			let row = RowView(title: quote.displayName)
			row.append(hCoreUIAssets.chevronRight.image)

			innerBag += section.append(row)
				.onValue {
					section.viewController?
						.present(
							QuoteCoverage(quote: quote).withCloseButton,
							style: .detented(.large),
							options: [
								.defaults, .prefersLargeTitles(true),
								.largeTitleDisplayMode(.always),
							]
						)
				}

			innerBag += {
				row.removeFromSuperview()
			}
			return innerBag
		}

		return (section, bag)
	}
}
