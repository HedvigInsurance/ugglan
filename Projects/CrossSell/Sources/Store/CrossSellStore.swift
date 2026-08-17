import Addons
import AppStateContainer
import Foundation

@MainActor
@PersistableStore
public final class CrossSellStore: AppStore {
    private let crossSellService = CrossSellService()

    @Published public internal(set) var crossSells: CrossSells?
    @Published public internal(set) var addonBanners: [AddonBanner] = []
    @Published public internal(set) var hasNewOffer: Bool = false

    @Transient @Published public internal(set) var fetchCrossSellError: String?
    @Transient @Published public internal(set) var fetchAddonBannersError: String?

    private static let lastSeenRecommendedKey = "lastSeenRecommendedProductId"
    private var lastSeenRecommendedProductId: String? {
        get { UserDefaults.standard.string(forKey: Self.lastSeenRecommendedKey) }
        set { UserDefaults.standard.set(newValue, forKey: Self.lastSeenRecommendedKey) }
    }

    public init() {}

    public func fetchCrossSell() async {
        do {
            crossSells = try await crossSellService.getCrossSell(source: .insurances)
            fetchCrossSellError = nil
        } catch {
            fetchCrossSellError = error.localizedDescription
        }
    }

    public func fetchAddonBanners() async {
        do {
            addonBanners = try await crossSellService.getAddonBanners(source: .crossSell)
            fetchAddonBannersError = nil
        } catch {
            addonBanners = []
            fetchAddonBannersError = error.localizedDescription
        }
    }

    public func fetchRecommendedCrossSellId() async {
        do {
            let recommended = try await crossSellService.getCrossSell(source: .home).recommended?.id
            hasNewOffer = recommended != nil && recommended != lastSeenRecommendedProductId
        } catch {}
    }

    public func setHasSeenRecommendedWith(id: String) {
        lastSeenRecommendedProductId = id
        hasNewOffer = false
    }
}
