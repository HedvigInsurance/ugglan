import Addons
import PresentableStore

public enum CrossSellAction: ActionProtocol, Hashable {
    case fetchCrossSell
    case fetchRecommendedCrossSellId
    case fetchAddonBanner
    case setCrossSells(crossSells: [CrossSell])
    case setHasSeenRecommendedWith(id: String)
    case setHasNewRecommendedCrossSell(hasNew: Bool)
    case setAddonBannerData(addonBanner: AddonBannerModel?)
}

public enum CrossSellLoadingAction: LoadingProtocol {
    case fetchCrossSell
    case fetchAddonBanner
}
