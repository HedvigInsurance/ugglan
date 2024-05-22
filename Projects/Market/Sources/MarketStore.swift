import Foundation
import Presentation
import hCore

public struct MarketState: StateProtocol {
    public var market: Market = .fromLocalization(Localization.Locale.currentLocale.value.market)

    public init() {}
}

public enum MarketAction: ActionProtocol {
    case selectMarket(market: Market)
    case selectLanguage(language: String)
    case dismissPicker
    case presentLanguageAndMarketPicker
    case loginButtonTapped
    case onboard
}

public final class MarketStore: StateStore<MarketState, MarketAction> {
    public override func effects(
        _ getState: @escaping () -> MarketState,
        _ action: MarketAction
    ) async {
        switch action {
        case let .selectMarket(market):
            Localization.Locale.currentLocale.value = market.preferredLanguage
        case let .selectLanguage(language):
            if let language = Localization.Locale(rawValue: language) {
                Localization.Locale.currentLocale.value = language
            }
        default:
            break
        }
    }

    public override func reduce(_ state: MarketState, _ action: MarketAction) -> MarketState {
        var newState = state

        switch action {
        case let .selectMarket(market):
            newState.market = market
        default:
            break
        }

        return newState
    }
}
