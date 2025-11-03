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
            fetchCrossSell: { CrossSell.getDefault }
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
            fetchCrossSell: { throw MockContractError.fetchCrossSells }
        )

        let store = CrossSellStore()
        self.store = store
        await store.sendAsync(.fetchCrossSell)
        try await Task.sleep(seconds: 0.5)
        assert(store.loadingState[.fetchCrossSell] != nil)
        assert(store.state.crossSells.isEmpty)
        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getCrossSell)
    }

    func testFetchAddonBannerDataSuccess() async {
        let mockService = MockData.createMockCrossSellService(
            fetchAddonBannerModel: { _ in AddonBannerModel.getDefault }
        )
        let store = CrossSellStore()
        self.store = store
        await store.sendAsync(.fetchAddonBanner)
        await waitUntil(description: "loading state") {
            store.loadingState[.fetchAddonBanner] == nil && store.state.addonBanner == AddonBannerModel.getDefault
        }

        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getAddonBannerModel)
    }

    func testFetchAddonBannerDataFailure() async throws {
        let mockService = MockData.createMockCrossSellService(
            fetchAddonBannerModel: { _ in throw MockContractError.fetchAddonBanner }
        )

        let store = CrossSellStore()
        self.store = store
        await store.sendAsync(.fetchAddonBanner)
        try await Task.sleep(seconds: 0.5)
        assert(store.loadingState[.fetchAddonBanner] != nil)
        assert(store.state.crossSells.isEmpty)
        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getAddonBannerModel)
    }
}

@MainActor
extension CrossSell {
    fileprivate static let getDefault: [CrossSell] = [
        .init(
            id: "1",
            title: "car",
            description: "description",
            imageUrl: nil,
            buttonDescription: "button description"
        ),
        .init(
            id: "2",
            title: "home",
            description: "description",
            imageUrl: nil,
            buttonDescription: "button description"
        ),
    ]
}

@MainActor
extension AddonBannerModel {
    fileprivate static let getDefault = AddonBannerModel(
        contractIds: ["contractId"],
        titleDisplayName: "display name",
        descriptionDisplayName: "description",
        badges: []
    )
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
