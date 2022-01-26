import Flow
import Foundation
import Presentation
import hCore
import hGraphQL
import Apollo

public struct MarketState: StateProtocol {
    var market: Market = .sweden
    var onboardingIdentifier: String? = nil

    public init() {}
}

public enum MarketAction: ActionProtocol {
    case selectMarket(market: Market)
    case setOnboardingIdentifier(id: String)
}

public final class MarketStore: StateStore<MarketState, MarketAction> {
    @Inject var client: ApolloClient
    @Inject var store: ApolloStore
    
    public override func effects(
        _ getState: @escaping () -> MarketState,
        _ action: MarketAction
    ) -> FiniteSignal<MarketAction>? {
        switch action {
        case let .selectMarket(market):
            Localization.Locale.currentLocale = market.preferredLanguage
            return self.client
                .perform(
                    mutation: GraphQL.CreateOnboardingQuoteCartMutation(input: .init(market: market.graphQL, locale: market.preferredLanguage.rawValue))
                ).map { data in
                    return .setOnboardingIdentifier(id: data.onboardingQuoteCartCreate.id.displayValue)
                }.valueThenEndSignal
        default:
            return nil
        }
    }

    public override func reduce(_ state: MarketState, _ action: MarketAction) -> MarketState {
        var newState = state

        switch action {
        case let .selectMarket(market):
            newState.market = market
        case .setOnboardingIdentifier(let id):
            newState.onboardingIdentifier = id
        }

        return newState
    }
}

extension Market {
    var graphQL: GraphQL.Market {
        switch self {
        case .denmark:
            return .denmark
        case .sweden:
            return .sweden
        case .norway:
            return .norway
        default:
            return .__unknown("")
        }
    }
}
