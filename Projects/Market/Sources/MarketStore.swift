import Flow
import Foundation
import Presentation
import hCore

public struct MarketState: StateProtocol {
    var market: Market = .sweden

    public init() {}
}

public enum MarketAction: ActionProtocol {
    case selectMarket(market: Market)
}

public final class MarketStore: StateStore<MarketState, MarketAction> {
    public override func effects(
        _ getState: @escaping () -> MarketState,
        _ action: MarketAction
    ) -> FiniteSignal<MarketAction>? {
        switch action {
        case let .selectMarket(market):
            Localization.Locale.currentLocale = market.preferredLanguage
        }

        return nil
    }

    public override func reduce(_ state: MarketState, _ action: MarketAction) -> MarketState {
        var newState = state

        switch action {
        case let .selectMarket(market):
            newState.market = market
        }

        return newState
    }
}
