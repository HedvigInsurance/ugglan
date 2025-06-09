import Addons
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
                let crossSells = try await self.crossSellService.getCrossSell(source: .home)
                let allCrossSells: [CrossSell] = {
                    if let recommended = crossSells.recommended {
                        return crossSells.others + [recommended]
                    }
                    return crossSells.others
                }()
                send(.setCrossSells(crossSells: allCrossSells))
            } catch let error {
                self.setError(error.localizedDescription, for: .fetchCrossSell)
            }
        case .fetchAddonBanner:
            do {
                let addonBanner = try await self.crossSellService.getAddonBannerModel(source: .crossSell)
                if let addonBanner {
                    send(.setAddonBannerData(addonBanner: addonBanner))
                }
            } catch {
                send(.setAddonBannerData(addonBanner: nil))
                self.setError(error.localizedDescription, for: .fetchAddonBanner)
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
        case let .setAddonBannerData(addonBanner):
            newState.addonBanner = addonBanner
        default:
            break
        }

        return newState
    }
}
