import Addons
import PresentableStore

public enum CrossSellAction: ActionProtocol, Hashable {
    case fetchCrossSell
    case fetchRecommendedCrossSellId
    case fetchAddonBanners
    case setCrossSells(crossSells: CrossSells)
    case setHasSeenRecommendedWith(id: String)
    case setHasNewRecommendedCrossSell(hasNew: Bool)
    case setAddonBanners(addonBanners: [AddonBanner])
}

public enum CrossSellLoadingAction: LoadingProtocol {
    case fetchCrossSell
    case fetchAddonBanners
}
