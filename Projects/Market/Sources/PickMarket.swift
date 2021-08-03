import Flow
import Form
import Foundation
import Presentation
import SwiftUI
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct PickMarket: PresentableView {
    typealias Result = Future<Market>
    
	let currentMarket: Market
	let availableLocales: [GraphQL.Locale]
	@PresentableStore var store: MarketStore
    
    var result: Future<Market> {
        Future { completion in
            let bag = DisposeBag()

            bag += store.actionSignal.onValue { action in
                if case let .selectMarket(market) = action {
                    completion(.success(market))
                }
            }

            return bag
        }
    }

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
        }.presentableTitle(L10n.MarketLanguageScreen.marketLabel)
	}
}
