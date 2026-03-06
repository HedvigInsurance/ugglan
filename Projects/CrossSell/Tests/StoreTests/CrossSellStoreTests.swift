import Addons
import PresentableStore
@preconcurrency import XCTest

@testable import CrossSell

@MainActor
final class CrossSellStoreTests: XCTestCase {
    weak var store: CrossSellStore?

    override func setUp() async throws {
        try await super.setUp()
        globalPresentableStoreContainer.deletePersistanceContainer()
    }

    @MainActor
    override func tearDown() async throws {
        try await super.tearDown()
        await waitUntil(description: "Store deinit") {
            self.store == nil
        }
    }

    func testFetchCrossSalesSuccess() async {
        let mockService = MockData.createMockCrossSellService(
            fetchCrossSell: { _ in CrossSell.getDefault }
        )
        let store = CrossSellStore()
        self.store = store
        await store.sendAsync(.fetchCrossSell)
        await waitUntil(description: "loading state") {
            store.loadingState[.fetchCrossSell] == nil && store.state.crossSells == CrossSell.getDefault
        }

        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getCrossSell)
    }

    func testFetchCrossSalesFailure() async throws {
        let mockService = MockData.createMockCrossSellService(
            fetchCrossSell: { _ in throw MockContractError.fetchCrossSells }
        )

        let store = CrossSellStore()
        self.store = store
        await store.sendAsync(.fetchCrossSell)
        try await Task.sleep(seconds: 0.5)
        assert(store.loadingState[.fetchCrossSell] != nil)
        assert(store.state.crossSells?.others.isEmpty == nil)
        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getCrossSell)
    }

    func testFetchAddonBannersDataSuccess() async {
        let mockService = MockData.createMockCrossSellService(
            fetchAddonBanners: { _ in AddonBanner.getDefault }
        )
        let store = CrossSellStore()
        self.store = store
        await store.sendAsync(.fetchAddonBanners)
        await waitUntil(description: "loading state") {
            store.loadingState[.fetchAddonBanners] == nil && store.state.addonBanners == AddonBanner.getDefault
        }

        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getAddonBanners)
    }

    func testFetchAddonBannerDataFailure() async throws {
        let mockService = MockData.createMockCrossSellService(
            fetchAddonBanners: { _ in throw MockContractError.fetchAddonBanners }
        )

        let store = CrossSellStore()
        self.store = store
        await store.sendAsync(.fetchAddonBanners)
        try await Task.sleep(seconds: 0.5)
        assert(store.loadingState[.fetchAddonBanners] != nil)
        assert(store.state.crossSells?.others.isEmpty == nil)
        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getAddonBanners)
    }
}

@MainActor
extension CrossSell {
    fileprivate static let getDefault: CrossSells = .init(
        recommended: nil,
        others: [
            .init(
                id: "1",
                title: "car",
                description: "description",
                buttonTitle: "button title",
                imageUrl: nil,
                buttonDescription: "button description"
            ),
            .init(
                id: "2",
                title: "home",
                description: "description",
                buttonTitle: "button title",
                imageUrl: nil,
                buttonDescription: "button description"
            ),
        ],
        discountAvailable: true
    )
}

@MainActor
extension CrossSellState {
    fileprivate var isEmpty: Bool {
        self.crossSells?.recommended == nil && self.crossSells?.others.isEmpty == true
    }
}

@MainActor
extension AddonBanner {
    fileprivate static let getDefault = [
        AddonBanner(
            contractIds: ["contractId"],
            titleDisplayName: "display name",
            descriptionDisplayName: "description",
            badges: [],
            addonType: .carPlus,

        )
    ]
}

@MainActor
extension XCTestCase {
    public func waitUntil(description: String, closure: @escaping () -> Bool) async {
        let exc = expectation(description: description)
        if closure() {
            exc.fulfill()
        } else {
            try! await Task.sleep(seconds: 0.1)
            Task {
                await self.waitUntil(description: description, closure: closure)
                if closure() {
                    exc.fulfill()
                }
            }
        }
        await fulfillment(of: [exc], timeout: 2)
    }
}
