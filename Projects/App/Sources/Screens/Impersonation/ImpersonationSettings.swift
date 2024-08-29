import Foundation
import Market
import StoreContainer
import SwiftUI
import hCore
import hCoreUI

struct ImpersonationSettings: View {
    @hPresentableStore var store: UgglanStore
    @hPresentableStore var marketStore: MarketStore
    @AppStorage(ApplicationState.key) public var state: ApplicationState.Screen = .notLoggedIn

    var body: some View {
        hForm {
            hSection(header: hText("Select locale")) {
                ForEach(Localization.Locale.allCases, id: \.rawValue) { locale in
                    hRow {
                        hText(locale.rawValue)
                    }
                    .onTap {
                        Task {
                            if let realMarket = Market(rawValue: locale.market.rawValue) {
                                marketStore.send(.selectMarket(market: realMarket))
                            }
                            Localization.Locale.currentLocale = locale
                            await marketStore.sendAsync(.selectLanguage(language: locale.rawValue))
                            ApplicationState.preserveState(.loggedIn)
                            ApplicationState.state = .loggedIn
                        }
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
