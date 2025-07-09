import Addons
import Foundation
import PresentableStore

public struct CrossSellState: StateProtocol {
    public init() {}

    public var crossSells: [CrossSell] = []
    public var addonBanner: AddonBannerModel?

    public var hasNewOffer = false

    internal var lastSeenRecommendedProductId: String? {
        return UserDefaults.standard.string(forKey: CrossSellState.lastSeenRecommendedkey)
    }

    internal func setLastSeenRecommendedProductId(_ id: String?) {
        UserDefaults.standard.set(id, forKey: CrossSellState.lastSeenRecommendedkey)
    }

    private static let lastSeenRecommendedkey = "lastSeenRecommendedProductId"

}
