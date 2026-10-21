import Addons
import TestDependencies
import Testing
import hCore

@testable import CrossSell

extension CrossSellDependencySuite {
    @MainActor
    final class CrossSellTests {
        private weak var sut: MockCrossSellService?

        @Test
        func getCrossSellSuccess() async {
            let crossSell: CrossSells = .init(
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
                        title: "pet",
                        description: "description",
                        buttonTitle: "button title",
                        webActionURL: "",
                        imageUrl: nil,
                        buttonDescription: "button description"
                    ),
                ]
            )

            // Scoped so mockService is released before expectServiceReleased() runs.
            await recordingErrors {
                let mockService = MockData.createMockCrossSellService(
                    fetchCrossSell: { _ in crossSell }
                )
                sut = mockService

                let respondedCrossSell = try await mockService.fetchCrossSell(.insurances)
                #expect(respondedCrossSell == crossSell)
            }

            await expectServiceReleased()
        }

        @Test
        func getAddonBannerSuccess() async {
            let addonBanner = [
                AddonBanner(
                    contractIds: ["contractId"],
                    displayTitle: "title",
                    displayDescription: "description",
                    badges: [],
                    addonType: .travelPlus
                )
            ]

            await recordingErrors {
                let mockService = MockData.createMockCrossSellService(
                    fetchAddonBanners: { _ in addonBanner }
                )
                sut = mockService

                let respondedAddonBanner = try await mockService.getAddonBanners(source: .insurances)
                #expect(respondedAddonBanner == addonBanner)
            }

            await expectServiceReleased()
        }

        private func expectServiceReleased() async {
            Dependencies.shared.remove(for: CrossSellClient.self)
            await delay(0.0000001)
            #expect(sut == nil, "the mock service must not outlive its dependency registration")
        }
    }
}
