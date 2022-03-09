import Apollo
import Flow
import Foundation
import Presentation
import hCore
import hGraphQL

public struct MarketState: StateProtocol {
    var market: Market = .sweden

    public init() {}
}

public enum MarketAction: ActionProtocol {
    case selectMarket(market: Market)
}

public final class MarketStore: StateStore<MarketState, MarketAction> {
    @Inject var client: ApolloClient
    @Inject var store: ApolloStore

    public override func effects(
        _ getState: @escaping () -> MarketState,
        _ action: MarketAction
    ) -> FiniteSignal<MarketAction>? {

        return nil
    }

    public override func reduce(_ state: MarketState, _ action: MarketAction) -> MarketState {

        return state
    }
}
