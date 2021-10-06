import Flow
import Form
import Foundation
import Presentation
import SwiftUI
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct PickMarket: View {
    let currentMarket: Market
    let availableLocales: [GraphQL.Locale]
    @PresentableStore var store: MarketStore

    var body: some View {
        hForm {
            hSection(Market.allCases, id: \.title) { market in
                hRow {
                    Image(uiImage: market.icon)
                    Spacer().frame(width: 16)
                    market.title.hText()
                }
                .withSelectedAccessory(market == currentMarket)
                .onTap {
                    store.send(.selectMarket(market: market))
                }
            }
            .dividerInsets(.leading, 50)
        }
    }
}

extension PickMarket {
    var journey: some JourneyPresentation {
        HostingJourney(
            MarketStore.self,
            rootView: self,
            style: .detented(.scrollViewContentSize),
            options: [.defaults, .prefersLargeTitles(true)]
        ) { action in
            if case .selectMarket = action {
                PopJourney()
            }
        }
        .configureTitle(L10n.MarketLanguageScreen.marketLabel)
        .withDismissButton
    }
}
