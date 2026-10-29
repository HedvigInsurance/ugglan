import Addons
import AppStateContainer
import TestDependencies
import Testing
import hCore

@testable import CrossSell

extension CrossSellDependencySuite {
    @MainActor
    final class CrossSellStoreTests {
        private weak var store: CrossSellStore?

        init() {
            globalAppStateContainer.clearPersistence()
        }

        // Test bodies are scoped so their stores are released; a live local would make this wait time out.
        private func expectStoreReleased() async {
            await waitUntil(description: "Store deinit") {
                self.store == nil
            }
            Dependencies.shared.remove(for: CrossSellClient.self)
        }

        @Test
        func fetchCrossSalesSuccess() async {
            do {
                let mockService = MockData.createMockCrossSellService(
                    fetchCrossSell: { _ in CrossSell.getDefault }
                )
                let store = CrossSellStore()
                self.store = store
                await store.fetchCrossSell()
                await waitUntil(description: "loading state") {
                    store.fetchCrossSellError == nil && store.crossSells == CrossSell.getDefault
                }

                #expect(mockService.events == [.getCrossSell])
            }

            await expectStoreReleased()
        }

        @Test
        func fetchCrossSalesFailure() async {
            do {
                let mockService = MockData.createMockCrossSellService(
                    fetchCrossSell: { _ in throw MockContractError.fetchCrossSells }
                )

                let store = CrossSellStore()
                self.store = store
                await store.fetchCrossSell()
                #expect(store.fetchCrossSellError != nil)
                #expect(store.crossSells == nil)
                #expect(mockService.events == [.getCrossSell])
            }

            await expectStoreReleased()
        }

        @Test
        func fetchHomeCrossSellsSuccess() async {
            do {
                let mockService = MockData.createMockCrossSellService(
                    fetchCrossSell: { _ in CrossSell.getDefaultWithRecommendation }
                )
                let store = CrossSellStore()
                self.store = store
                store.setHasSeenRecommendedWith(id: "previously-seen-id")
                await store.fetchHomeCrossSells()
                await waitUntil(description: "loading state") {
                    store.homeCrossSells == CrossSell.getDefaultWithRecommendation
                }

                #expect(store.hasNewOffer == true)
                #expect(mockService.events == [.getCrossSell, .getCrossSell])
            }

            await expectStoreReleased()
        }

        @Test
        func fetchAddonBannersDataSuccess() async {
            do {
                let mockService = MockData.createMockCrossSellService(
                    fetchAddonBanners: { _ in AddonBanner.getDefault }
                )
                let store = CrossSellStore()
                self.store = store
                await store.fetchAddonBanners()
                await waitUntil(description: "loading state") {
                    store.fetchAddonBannersError == nil && store.addonBanners == AddonBanner.getDefault
                }

                #expect(mockService.events == [.getAddonBanners])
            }

            await expectStoreReleased()
        }

        @Test
        func fetchAddonBannerDataFailure() async {
            do {
                let mockService = MockData.createMockCrossSellService(
                    fetchAddonBanners: { _ in throw MockContractError.fetchAddonBanners }
                )

                let store = CrossSellStore()
                self.store = store
                await store.fetchAddonBanners()
                #expect(store.fetchAddonBannersError != nil)
                #expect(store.addonBanners.isEmpty)
                #expect(mockService.events == [.getAddonBanners])
            }

            await expectStoreReleased()
        }
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
                webActionURL: "",
                imageUrl: nil,
                buttonDescription: "button description"
            ),
            .init(
                id: "2",
                title: "home",
                description: "description",
                buttonTitle: "button title",
                webActionURL: "",
                imageUrl: nil,
                buttonDescription: "button description"
            ),
        ]
    )

    fileprivate static let getDefaultWithRecommendation: CrossSells = .init(
        recommended: .insurance(
            .init(
                id: "new-recommended-id",
                title: "car",
                description: "description",
                buttonTitle: "button title",
                webActionURL: "",
                imageUrl: nil,
                buttonDescription: "button description"
            )
        ),
        others: [
            .init(
                id: "1",
                title: "home",
                description: "description",
                buttonTitle: "button title",
                webActionURL: "",
                imageUrl: nil,
                buttonDescription: "button description"
            )
        ]
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
