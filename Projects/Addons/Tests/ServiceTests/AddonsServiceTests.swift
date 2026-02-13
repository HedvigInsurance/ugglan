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
        let mockService = MockData.createMockAddonsService(fetchAddonOffer: { _ in testTravelOfferNoActive })

        sut = mockService

        let respondedAddonData = try await mockService.getAddonOffer(contractId: "contractId")

        assert(respondedAddonData == testTravelOfferNoActive)
    }

    func testGetAddonBannersSuccess() async throws {
        let mockService = MockData.createMockAddonsService(fetchBanners: { _ in [testAddonBanner] })

        sut = mockService

        let respondedBanners = try await mockService.getAddonBanners(source: .insurances)

        assert(respondedBanners == [testAddonBanner])
        assert(respondedBanners.first?.titleDisplayName == "Travel Plus")
    }
}
