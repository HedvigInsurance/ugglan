@preconcurrency import XCTest
import hCore

@testable import Addons

@MainActor
final class RemoveAddonViewModelTests: XCTestCase {
    weak var sut: MockAddonsService?
    weak var vm: RemoveAddonViewModel?

    override func tearDown() async throws {
        try await super.tearDown()
        Dependencies.shared.remove(for: AddonsClient.self)
        XCTAssertNil(sut)
        XCTAssertNil(vm)
    }

    func testGetAddonRemoveOfferCostSuccess() async throws {
        let expectedCost = ItemCost(premium: .init(gross: .sek(399), net: .sek(399)), discounts: [])
        let mockService = MockData.createMockAddonsService(
            fetchAddonRemoveOffer: { _ in testRemoveOffer },
            fetchAddonRemoveOfferCost: { _, _ in expectedCost }
        )

        sut = mockService

        let model = RemoveAddonViewModel(.init(offer: testRemoveOffer, preselectedAddons: Set(), cost: nil))

        vm = model
        try await Task.sleep(seconds: 0.03)

        model.toggleAddon(testRemoveOffer.removableAddons[0])
        await model.getAddonRemoveOfferCost()

        assert(model.addonRemoveOfferCost == expectedCost)
        assert(model.fetchingCostState == .success)
    }

    func testConfirmRemovalSuccess() async throws {
        let mockService = MockData.createMockAddonsService(
            fetchAddonRemoveOffer: { _ in testRemoveOffer },
            confirmAddonRemoval: { _, _ in }
        )

        sut = mockService

        let model = RemoveAddonViewModel(.init(offer: testRemoveOffer, preselectedAddons: Set(), cost: nil))

        vm = model
        try await Task.sleep(seconds: 0.03)

        await model.confirmRemoval()

        assert(model.submittingState == .success)
    }

    func testConfirmRemovalFailure() async throws {
        let mockService = MockData.createMockAddonsService(
            fetchAddonRemoveOffer: { _ in testRemoveOffer },
            confirmAddonRemoval: { _, _ in throw AddonsError.somethingWentWrong }
        )

        sut = mockService

        let model = RemoveAddonViewModel(.init(offer: testRemoveOffer, preselectedAddons: Set(), cost: nil))

        vm = model
        try await Task.sleep(seconds: 0.03)

        await model.confirmRemoval()

        assert(model.submittingState == .error(errorMessage: AddonsError.somethingWentWrong.localizedDescription))
    }
}
