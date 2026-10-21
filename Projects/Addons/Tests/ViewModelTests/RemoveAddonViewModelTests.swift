import Testing
import hCore

@testable import Addons

extension AddonsDependencySuite {
    @MainActor
    final class RemoveAddonViewModelTests {
        private weak var sut: MockAddonsService?
        private weak var vm: RemoveAddonViewModel?

        // Stands in for the old tearDown, which cannot become deinit: deinit is nonisolated and this is
        // main-actor work. Each test body is scoped in a do block because XCTest ran tearDown after the
        // test frame was gone, and this runs inside it, where live locals would still own both.
        private func expectServiceAndViewModelReleased() {
            Dependencies.shared.remove(for: AddonsClient.self)
            #expect(sut == nil, "the mock service must not outlive its dependency registration")
            #expect(vm == nil, "the view model must not outlive the test that created it")
        }

        @Test
        func getAddonRemoveOfferCostSuccess() async {
            do {
                let expectedCost = ItemCost(premium: .init(gross: .sek(399), net: .sek(399)), discounts: [])
                let mockService = MockData.createMockAddonsService(
                    fetchAddonRemoveOffer: { _ in testRemoveOffer },
                    fetchAddonRemoveOfferCost: { _, _ in expectedCost }
                )

                sut = mockService

                let model = RemoveAddonViewModel(.init(offer: testRemoveOffer, preselectedAddons: Set(), cost: nil))

                vm = model

                model.toggleAddon(testRemoveOffer.removableAddons[0])
                await model.getAddonRemoveOfferCost()

                #expect(model.addonRemoveOfferCost == expectedCost)
                #expect(model.fetchingCostState == .success)
            }

            expectServiceAndViewModelReleased()
        }

        @Test
        func confirmRemovalSuccess() async {
            do {
                let mockService = MockData.createMockAddonsService(
                    fetchAddonRemoveOffer: { _ in testRemoveOffer },
                    confirmAddonRemoval: { _, _ in }
                )

                sut = mockService

                let model = RemoveAddonViewModel(.init(offer: testRemoveOffer, preselectedAddons: Set(), cost: nil))

                vm = model

                await model.confirmRemoval()

                #expect(model.submittingState == .success)
            }

            expectServiceAndViewModelReleased()
        }

        @Test
        func confirmRemovalFailure() async {
            do {
                let mockService = MockData.createMockAddonsService(
                    fetchAddonRemoveOffer: { _ in testRemoveOffer },
                    confirmAddonRemoval: { _, _ in throw AddonsError.somethingWentWrong }
                )

                sut = mockService

                let model = RemoveAddonViewModel(.init(offer: testRemoveOffer, preselectedAddons: Set(), cost: nil))

                vm = model

                await model.confirmRemoval()

                #expect(
                    model.submittingState == .error(errorMessage: AddonsError.somethingWentWrong.localizedDescription)
                )
            }

            expectServiceAndViewModelReleased()
        }
    }
}
