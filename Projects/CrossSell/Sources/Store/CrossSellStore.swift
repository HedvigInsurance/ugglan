import PresentableStore
import hCore

public final class CrossSellStore: LoadingStateStore<CrossSellState, CrossSellAction, CrossSellLoadingAction> {
    let crossSellService = CrossSellService()
    public override func effects(
        _ getState: @escaping () -> CrossSellState,
        _ action: CrossSellAction
    ) async {
        switch action {
        case .fetchCrossSell:
            do {
                let crossSells = try await self.crossSellService.getCrossSell()
                send(.setCrossSells(crossSells: crossSells))
            } catch let error {
                self.setError(error.localizedDescription, for: .fetchCrossSell)
            }
        default:
            break
        }
    }

    public override func reduce(_ state: CrossSellState, _ action: CrossSellAction) async -> CrossSellState {
        var newState = state
        switch action {
        case let .setCrossSells(crossSells):
            newState.crossSells = crossSells
        default:
            break
        }

        return newState
    }
}
