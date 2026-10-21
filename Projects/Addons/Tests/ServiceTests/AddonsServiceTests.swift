import TestDependencies
import Testing
import hCore

@testable import Addons

extension AddonsDependencySuite {
    @MainActor
    final class AddonsServiceTests {
        private weak var sut: MockAddonsService?

        // Test bodies are scoped so their locals are released before this check runs.
        private func expectServiceReleased() {
            Dependencies.shared.remove(for: AddonsClient.self)
            #expect(sut == nil, "the mock service must not outlive its dependency registration")
        }

        @Test
        func fetchAddonDataSuccess() async {
            await recordingErrors {
                let mockService = MockData.createMockAddonsService(
                    fetchAddonOffer: { _, _ in .offer(testTravelOfferNoActive) }
                )

                sut = mockService

                let respondedAddonData = try await mockService.getAddonOffer(
                    contractInfo: testAddonContractInfo,
                    source: .insurances
                )

                #expect(respondedAddonData == .offer(testTravelOfferNoActive))
            }

            expectServiceReleased()
        }

        @Test
        func fetchAddonDeflectSuccess() async {
            await recordingErrors {
                let mockService = MockData.createMockAddonsService(
                    fetchAddonOffer: { _, _ in .deflect(testDeflectUpgradeTier) }
                )

                sut = mockService

                let respondedAddonData = try await mockService.getAddonOffer(
                    contractInfo: testAddonContractInfo,
                    source: .insurances
                )

                #expect(respondedAddonData == .deflect(testDeflectUpgradeTier))
            }

            expectServiceReleased()
        }

        @Test
        func getAddonBannersSuccess() async {
            await recordingErrors {
                let mockService = MockData.createMockAddonsService(fetchBanners: { _ in [testAddonBanner] })

                sut = mockService

                let respondedBanners = try await mockService.getAddonBanners(source: .insurances)

                #expect(respondedBanners == [testAddonBanner])
            }

            expectServiceReleased()
        }

        @Test
        func getAddonRemoveOfferSuccess() async {
            await recordingErrors {
                let mockService = MockData.createMockAddonsService(fetchAddonRemoveOffer: { _ in testRemoveOffer })

                sut = mockService

                let respondedOffer = try await mockService.getAddonRemoveOffer(
                    contractInfo: .init(contractId: "cId", displayName: "dName", exposureName: "eName")
                )

                #expect(respondedOffer == testRemoveOffer)
                #expect(mockService.events == [.getAddonRemoveOffer])
            }

            expectServiceReleased()
        }

        @Test
        func confirmAddonRemovalSuccess() async {
            await recordingErrors {
                let mockService = MockData.createMockAddonsService(confirmAddonRemoval: { _, _ in })

                sut = mockService

                try await mockService.confirmAddonRemoval(contractId: "cId", addonIds: ["aId"])

                #expect(mockService.events == [.confirmAddonRemoval])
            }

            expectServiceReleased()
        }

        @Test
        func submitAddonsSuccess() async {
            await recordingErrors {
                let mockService = MockData.createMockAddonsService(addonsSubmit: { _, _ in })

                sut = mockService

                try await mockService.submitAddons(quoteId: "qId", addonIds: ["aId"])

                #expect(mockService.events == [.submitAddon])
            }

            expectServiceReleased()
        }

        @Test
        func getAddonOfferCostSuccess() async {
            await recordingErrors {
                let expectedCost = ItemCost(premium: .init(gross: .sek(348), net: .sek(328)), discounts: [])
                let mockService = MockData.createMockAddonsService(fetchAddonOfferCost: { _, _ in expectedCost })

                sut = mockService

                let respondedCost = try await mockService.getAddonOfferCost(quoteId: "qId", addonIds: ["aId"])

                #expect(respondedCost == expectedCost)
                #expect(mockService.events == [.getAddonOfferCost])
            }

            expectServiceReleased()
        }

        @Test
        func getAddonRemoveOfferCostSuccess() async {
            await recordingErrors {
                let expectedCost = ItemCost(premium: .init(gross: .sek(399), net: .sek(399)), discounts: [])
                let mockService = MockData.createMockAddonsService(fetchAddonRemoveOfferCost: { _, _ in expectedCost })

                sut = mockService

                let respondedCost = try await mockService.getAddonRemoveOfferCost(contractId: "cId", addonIds: ["aId"])

                #expect(respondedCost == expectedCost)
                #expect(mockService.events == [.getAddonRemoveOfferCost])
            }

            expectServiceReleased()
        }
    }
}
