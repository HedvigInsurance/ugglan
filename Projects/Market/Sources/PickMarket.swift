import Flow
import Form
import Foundation
import Presentation
import SwiftUI
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct PickMarketView: View {
	let currentMarket: Market
	let availableLocales: [GraphQL.Locale]
	var store: MarketStore

	var body: some View {
		hForm {
			hSectionList(Market.allCases, id: \.title) { market in
				hRow {
					Image(uiImage: market.icon)
					Spacer().frame(width: 16)
					hText(text: market.title, style: .body)
					Spacer()
					if market == currentMarket {
						Image(uiImage: Asset.checkmark.image)
					}
				}
				.onTap {
					store.send(.selectMarket(market: market))
				}
			}
			.dividerInsets(.leading, 50)
		}
	}
}

struct PickMarket: Presentable {
	let currentMarket: Market
	let availableLocales: [GraphQL.Locale]

	func materialize() -> (UIViewController, Future<Market>) {
		let store: MarketStore = get()

		let viewController = UIHostingController(
			rootView: PickMarketView(
				currentMarket: currentMarket,
				availableLocales: availableLocales,
				store: store
			)
		)

		viewController.navigationItem.title = "test"

		return (
			viewController,
			Future { completion in
				let bag = DisposeBag()

				bag += store.actionSignal.onValue { action in
					if case let .selectMarket(market) = action {
						completion(.success(market))
					}
				}

				return bag
			}
		)
	}
}
