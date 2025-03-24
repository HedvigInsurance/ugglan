import Addons
import PresentableStore

public struct CrossSellState: StateProtocol {
    public init() {}

    public var crossSells: [CrossSell] = []
    public var addonBanner: AddonBannerModel?

    public var hasUnseenCrossSell: Bool {
        crossSells.contains(where: { crossSell in !crossSell.hasBeenSeen })
    }
}
