import TestDependencies
import Testing
import hCore

@testable import AddonsCore

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
                var receivedSource: AddonSource?
                let mockService = MockData.createMockAddonsService(
                    fetchAddonOffer: { _, source in
                        receivedSource = source
                        return .offer(testTravelOfferNoActive)
                    }
                )

                sut = mockService

                let respondedAddonData = try await AddonsService()
                    .getAddonOffer(
                        contractInfo: testAddonContractInfo,
                        source: .insurances
                    )

                #expect(respondedAddonData == .offer(testTravelOfferNoActive))
                #expect(receivedSource == .insurances)
                #expect(mockService.events == [.getAddon])
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

                let respondedAddonData = try await AddonsService()
                    .getAddonOffer(
                        contractInfo: testAddonContractInfo,
                        source: .insurances
                    )

                #expect(respondedAddonData == .deflect(testDeflectUpgradeTier))
            }

            expectServiceReleased()
        }

        @Test
        func getAddonRemoveOfferSuccess() async {
            await recordingErrors {
                let mockService = MockData.createMockAddonsService(fetchAddonRemoveOffer: { _ in testRemoveOffer })

                sut = mockService

                let respondedOffer = try await AddonsService()
                    .getAddonRemoveOffer(
                        contractInfo: testAddonContractInfo
                    )

                #expect(respondedOffer == testRemoveOffer)
                #expect(mockService.events == [.getAddonRemoveOffer])
            }

            expectServiceReleased()
        }

        @Test
        func confirmAddonRemovalSuccess() async {
            await recordingErrors {
                var received: (contractId: String, addonIds: Set<String>)?
                let mockService = MockData.createMockAddonsService(
                    confirmAddonRemoval: { contractId, addonIds in received = (contractId, addonIds) }
                )

                sut = mockService

                let elapsed = try await ContinuousClock()
                    .measure {
                        try await AddonsService().confirmAddonRemoval(contractId: "cId", addonIds: ["aId"])
                    }

                #expect(mockService.events == [.confirmAddonRemoval])
                #expect(received?.contractId == "cId")
                #expect(received?.addonIds == ["aId"])
                #expect(elapsed >= .seconds(3), "the processing screen relies on a minimum duration")
            }

            expectServiceReleased()
        }

        @Test
        func submitAddonsSuccess() async {
            await recordingErrors {
                var received: (quoteId: String, addonIds: Set<String>)?
                let mockService = MockData.createMockAddonsService(
                    addonsSubmit: { quoteId, addonIds in received = (quoteId, addonIds) }
                )

                sut = mockService

                let elapsed = try await ContinuousClock()
                    .measure {
                        try await AddonsService().submitAddons(quoteId: "qId", selectedAddonIds: ["aId"])
                    }

                #expect(mockService.events == [.submitAddon])
                #expect(received?.quoteId == "qId")
                #expect(received?.addonIds == ["aId"])
                #expect(elapsed >= .seconds(3), "the processing screen relies on a minimum duration")
            }

            expectServiceReleased()
        }

        @Test
        func getAddonOfferCostSuccess() async {
            await recordingErrors {
                let expectedCost = testAddonOfferCost
                let mockService = MockData.createMockAddonsService(fetchAddonOfferCost: { _, _ in expectedCost })

                sut = mockService

                let respondedCost = try await AddonsService().getAddonOfferCost(quoteId: "qId", addonIds: ["aId"])

                #expect(respondedCost == expectedCost)
                #expect(mockService.events == [.getAddonOfferCost])
            }

            expectServiceReleased()
        }

        @Test
        func getAddonRemoveOfferCostSuccess() async {
            await recordingErrors {
                let expectedCost = testAddonOfferCost
                let mockService = MockData.createMockAddonsService(fetchAddonRemoveOfferCost: { _, _ in expectedCost })

                sut = mockService

                let respondedCost = try await AddonsService()
                    .getAddonRemoveOfferCost(
                        contractId: "cId",
                        addonIds: ["aId"]
                    )

                #expect(respondedCost == expectedCost)
                #expect(mockService.events == [.getAddonRemoveOfferCost])
            }

            expectServiceReleased()
        }
    }
}
