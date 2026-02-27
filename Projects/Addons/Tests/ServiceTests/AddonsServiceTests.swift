@preconcurrency import XCTest
import hCore

@testable import Addons

@MainActor
final class AddonsServiceTests: XCTestCase {
    weak var sut: MockAddonsService?

    override func tearDown() async throws {
        try await super.tearDown()
        Dependencies.shared.remove(for: AddonsClient.self)
        XCTAssertNil(sut)
    }

    func testFetchAddonDataSuccess() async throws {
        let mockService = MockData.createMockAddonsService(
            fetchAddonOffer: { _, _ in .offer(testTravelOfferNoActive) }
        )

        sut = mockService

        let respondedAddonData = try await mockService.getAddonOffer(
            config: testAddonConfig,
            source: .insurances
        )

        assert(respondedAddonData == .offer(testTravelOfferNoActive))
    }

    func testFetchAddonDeflectSuccess() async throws {
        let mockService = MockData.createMockAddonsService(
            fetchAddonOffer: { _, _ in .deflect(testDeflectUpgradeTier) }
        )

        sut = mockService

        let respondedAddonData = try await mockService.getAddonOffer(
            config: testAddonConfig,
            source: .insurances
        )

        assert(respondedAddonData == .deflect(testDeflectUpgradeTier))
    }

    func testGetAddonBannersSuccess() async throws {
        let mockService = MockData.createMockAddonsService(fetchBanners: { _ in [testAddonBanner] })

        sut = mockService

        let respondedBanners = try await mockService.getAddonBanners(source: .insurances)

        assert(respondedBanners == [testAddonBanner])
    }

    func testGetAddonRemoveOfferSuccess() async throws {
        let mockService = MockData.createMockAddonsService(fetchAddonRemoveOffer: { _ in testRemoveOffer })

        sut = mockService

        let respondedOffer = try await mockService.getAddonRemoveOffer(
            config: .init(contractId: "cId", exposureName: "eName", displayName: "dName")
        )

        assert(respondedOffer == testRemoveOffer)
        assert(mockService.events == [.getAddonRemoveOffer])
    }

    func testConfirmAddonRemovalSuccess() async throws {
        let mockService = MockData.createMockAddonsService(confirmAddonRemoval: { _, _ in })

        sut = mockService

        try await mockService.confirmAddonRemoval(contractId: "cId", addonIds: ["aId"])

        assert(mockService.events == [.confirmAddonRemoval])
    }

    func testSubmitAddonsSuccess() async throws {
        let mockService = MockData.createMockAddonsService(addonsSubmit: { _, _ in })

        sut = mockService

        try await mockService.submitAddons(quoteId: "qId", addonIds: ["aId"])

        assert(mockService.events == [.submitAddon])
    }

    func testGetAddonOfferCostSuccess() async throws {
        let expectedCost = ItemCost(premium: .init(gross: .sek(348), net: .sek(328)), discounts: [])
        let mockService = MockData.createMockAddonsService(fetchAddonOfferCost: { _, _ in expectedCost })

        sut = mockService

        let respondedCost = try await mockService.getAddonOfferCost(quoteId: "qId", addonIds: ["aId"])

        assert(respondedCost == expectedCost)
        assert(mockService.events == [.getAddonOfferCost])
    }

    func testGetAddonRemoveOfferCostSuccess() async throws {
        let expectedCost = ItemCost(premium: .init(gross: .sek(399), net: .sek(399)), discounts: [])
        let mockService = MockData.createMockAddonsService(fetchAddonRemoveOfferCost: { _, _ in expectedCost })

        sut = mockService

        let respondedCost = try await mockService.getAddonRemoveOfferCost(contractId: "cId", addonIds: ["aId"])

        assert(respondedCost == expectedCost)
        assert(mockService.events == [.getAddonRemoveOfferCost])
    }
}
