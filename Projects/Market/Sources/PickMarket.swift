import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct PickMarket {
	let currentMarket: Market
	let availableLocales: [GraphQL.Locale]
}

extension PickMarket: Presentable {
	func materialize() -> (UIViewController, Future<Market>) {
		let viewController = UIViewController()
		viewController.title = L10n.MarketLanguageScreen.marketLabel
		let bag = DisposeBag()

		let form = FormView()
		bag += viewController.install(form)

		let section = form.appendSection()

		return (
			viewController,
			Future { completion in
				Market.allCases.filter { market in
					availableLocales.first { locale -> Bool in
						locale.rawValue.lowercased().contains(market.id)
					} != nil
				}.forEach { market in let row = RowView(title: market.title)

					let iconImageView = UIImageView()
					iconImageView.contentMode = .scaleAspectFit
					iconImageView.image = market.icon
					row.prepend(iconImageView)

					row.setCustomSpacing(16, after: iconImageView)

					if market == currentMarket { row.append(Asset.checkmark.image) }

					bag += section.append(row).onValue { completion(.success(market)) }
				}

				return bag
			}
		)
	}
}
