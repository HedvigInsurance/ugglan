import Flow
import Foundation
import Presentation

public struct MarketState: StateProtocol {
  var market: Market = .sweden

  public init() {}
}

public enum MarketAction: ActionProtocol {
  case selectMarket(market: Market)

  #if compiler(<5.5)
    public func encode(to encoder: Encoder) throws {
      #warning("Waiting for automatic codable conformance from Swift 5.5, remove this when we have upgraded XCode")
      fatalError()
    }

    public init(
      from decoder: Decoder
    ) throws {
      #warning("Waiting for automatic codable conformance from Swift 5.5, remove this when we have upgraded XCode")
      fatalError()
    }
  #endif
}

public final class MarketStore: StateStore<MarketState, MarketAction> {
  public override func effects(
    _ getState: () -> MarketState,
    _ action: MarketAction
  ) -> FiniteSignal<MarketAction>? {
    switch action {
    default:
      break
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
