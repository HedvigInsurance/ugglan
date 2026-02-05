import Addons
import Foundation
import PresentableStore

public struct CrossSellState: StateProtocol {
    public init() {}

    public var crossSells: CrossSells?

    public var addonBanners: [AddonBanner] = []

    public var hasNewOffer = false

    var lastSeenRecommendedProductId: String? {
        UserDefaults.standard.string(forKey: CrossSellState.lastSeenRecommendedkey)
    }

    func setLastSeenRecommendedProductId(_ id: String?) {
        UserDefaults.standard.set(id, forKey: CrossSellState.lastSeenRecommendedkey)
    }

    private static let lastSeenRecommendedkey = "lastSeenRecommendedProductId"
}
