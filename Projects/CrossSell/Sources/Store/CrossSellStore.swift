import Addons
import hCore
import PresentableStore

public final class CrossSellStore: LoadingStateStore<CrossSellState, CrossSellAction, CrossSellLoadingAction> {
    let crossSellService = CrossSellService()
    override public func effects(
        _: @escaping () -> CrossSellState,
        _ action: CrossSellAction
    ) async {
        switch action {
        case .fetchCrossSell:
            do {
                let crossSells = try await crossSellService.getCrossSell()
                send(.setCrossSells(crossSells: crossSells))
            } catch {
                setError(error.localizedDescription, for: .fetchCrossSell)
            }
        case .fetchAddonBanner:
            do {
                let addonBanner = try await crossSellService.getAddonBannerModel(source: .crossSell)
                if let addonBanner {
                    send(.setAddonBannerData(addonBanner: addonBanner))
                }
            } catch {
                send(.setAddonBannerData(addonBanner: nil))
                setError(error.localizedDescription, for: .fetchAddonBanner)
            }
        case .fetchRecommendedCrossSellId:
            do {
                let crossSellsV2 = try await crossSellService.getCrossSell(source: .home)
                let recommendedProductId = crossSellsV2.recommended?.id
                let lastSeenRecommendedProductId = state.lastSeenRecommendedProductId
                if recommendedProductId != nil, recommendedProductId != lastSeenRecommendedProductId {
                    send(.setHasNewRecommendedCrossSell(hasNew: true))
                } else {
                    send(.setHasNewRecommendedCrossSell(hasNew: false))
                }
            } catch {}
        case .setHasSeenRecommendedWith:
            send(.setHasNewRecommendedCrossSell(hasNew: false))
        default:
            break
        }
    }

    override public func reduce(_ state: CrossSellState, _ action: CrossSellAction) async -> CrossSellState {
        var newState = state
        switch action {
        case let .setCrossSells(crossSells):
            newState.crossSells = crossSells
        case let .setAddonBannerData(addonBanner):
            newState.addonBanner = addonBanner
        case let .setHasNewRecommendedCrossSell(hasNew):
            newState.hasNewOffer = hasNew
        case let .setHasSeenRecommendedWith(id):
            newState.setLastSeenRecommendedProductId(id)
        default:
            break
        }

        return newState
    }
}
