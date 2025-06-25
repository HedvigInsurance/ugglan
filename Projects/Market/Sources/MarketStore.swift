import Foundation
import PresentableStore
import hCore

public struct MarketState: StateProtocol {
    public init() {}
}

public enum MarketAction: ActionProtocol {
    case selectLanguage(language: String)
}

public final class MarketStore: StateStore<MarketState, MarketAction> {
    public override func effects(
        _ getState: @escaping () -> MarketState,
        _ action: MarketAction
    ) async {
        switch action {
        case let .selectLanguage(language):
            if let language = Localization.Locale(rawValue: language) {
                Localization.Locale.currentLocale.send(language)
            }
        }
    }

    public override func reduce(_ state: MarketState, _ action: MarketAction) async -> MarketState {
        switch action {
        default:
            break
        }

        return state
    }
}
