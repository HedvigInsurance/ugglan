import Addons
import AppStateContainer
import XCTest

@testable import CrossSell

@MainActor
final class CrossSellStoreTests: XCTestCase {
    weak var store: CrossSellStore?

    override func setUp() async throws {
        try await super.setUp()
        globalAppStateContainer.clearPersistence()
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
        await store.fetchCrossSell()
        await waitUntil(description: "loading state") {
            store.fetchCrossSellError == nil && store.crossSells == CrossSell.getDefault
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
        await store.fetchCrossSell()
        try await Task.sleep(seconds: 0.5)
        assert(store.fetchCrossSellError != nil)
        assert(store.crossSells?.others.isEmpty == nil)
        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getCrossSell)
    }

    func testFetchAddonBannersDataSuccess() async {
        let mockService = MockData.createMockCrossSellService(
            fetchAddonBanners: { _ in AddonBanner.getDefault }
        )
        let store = CrossSellStore()
        self.store = store
        await store.fetchAddonBanners()
        await waitUntil(description: "loading state") {
            store.fetchAddonBannersError == nil && store.addonBanners == AddonBanner.getDefault
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
        await store.fetchAddonBanners()
        try await Task.sleep(seconds: 0.5)
        assert(store.fetchAddonBannersError != nil)
        assert(store.crossSells?.others.isEmpty == nil)
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
extension AddonBanner {
    fileprivate static let getDefault = [
        AddonBanner(
            contractIds: ["contractId"],
            displayTitle: "display name",
            displayDescription: "description",
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
