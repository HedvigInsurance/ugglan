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
    override public func effects(
        _: @escaping () -> MarketState,
        _ action: MarketAction
    ) async {
        switch action {
        case let .selectLanguage(language):
            if let language = Localization.Locale(rawValue: language) {
                Localization.Locale.currentLocale.send(language)
            }
        }
    }

    override public func reduce(_ state: MarketState, _ action: MarketAction) async -> MarketState {
        switch action {
        default:
            break
        }

        return state
    }
}
