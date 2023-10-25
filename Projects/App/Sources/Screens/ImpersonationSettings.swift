import Foundation
import Market
import Presentation
import SwiftUI
import hCore
import hCoreUI

struct ImpersonationSettings: View {
    @PresentableStore var store: UgglanStore
    @PresentableStore var marketStore: MarketStore

    var body: some View {
        hForm {
            hSection(header: hText("Select locale")) {
                ForEach(Localization.Locale.allCases, id: \.rawValue) { locale in
                    hRow {
                        hText(locale.rawValue)
                    }
                    .onTap {
                        if let realMarket = Market(rawValue: locale.market.rawValue) {
                            marketStore.send(.selectMarket(market: realMarket))
                        }
                        marketStore.send(.selectLanguage(language: locale.rawValue))
                        Localization.Locale.currentLocale = locale
                        store.send(.showLoggedIn)
                    }
                }
            }
            .withFooter {
                hText(
                    "BEWARE: if you select a locale that doesn't match the market of the user weird things will happen."
                )
            }
        }
    }
}
