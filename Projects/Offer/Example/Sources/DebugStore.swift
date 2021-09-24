import Flow
import Foundation
import Presentation

public struct DebugState: StateProtocol {
    public init() {}
}

public enum DebugAction: ActionProtocol {
    case openOffer(fullscreen: Bool, prefersLargeTitles: Bool)
    case openDataCollection
}

public final class DebugStore: StateStore<DebugState, DebugAction> {
    public override func effects(
        _ getState: @escaping () -> DebugState,
        _ action: DebugAction
    ) -> FiniteSignal<DebugAction>? {
        return nil
    }

    public override func reduce(_ state: DebugState, _ action: DebugAction) -> DebugState {
        return state
    }
}
