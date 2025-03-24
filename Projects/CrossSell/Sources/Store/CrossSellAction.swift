import Addons
import PresentableStore

public enum CrossSellAction: ActionProtocol, Hashable {
    case fetchCrossSell
    case fetchAddonBanner
    case setCrossSells(crossSells: [CrossSell])
    case setAddonBannerData(addonBanner: AddonBannerModel)
}

public enum CrossSellLoadingAction: LoadingProtocol {
    case fetchCrossSell
    case fetchAddonBanner
}
