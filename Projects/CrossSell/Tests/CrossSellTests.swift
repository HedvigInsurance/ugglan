import Addons
@preconcurrency import XCTest
import hCore

@testable import CrossSell

@MainActor
final class CrossSellTests: XCTestCase {
    weak var sut: MockCrossSellService?

    override func tearDown() async throws {
        Dependencies.shared.remove(for: CrossSellClient.self)
        try await Task.sleep(seconds: 0.0000001)

        XCTAssertNil(sut)
    }

    func testGetCrossSellSuccess() async {
        let crossSell: CrossSells = .init(
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
                    title: "pet",
                    description: "description",
                    buttonTitle: "button title",
                    imageUrl: nil,
                    buttonDescription: "button description"
                ),
            ]
        )

        let mockService = MockData.createMockCrossSellService(
            fetchCrossSell: { _ in crossSell }
        )
        sut = mockService

        let respondedCrossSell = try! await mockService.fetchCrossSell(.insurances)
        assert(respondedCrossSell == crossSell)
    }

    func testGetAddonBannerSuccess() async {
        let addonBannerModel = AddonBannerModel(
            contractIds: ["contractId"],
            titleDisplayName: "title",
            descriptionDisplayName: "description",
            badges: []
        )

        let mockService = MockData.createMockCrossSellService(
            fetchAddonBannerModel: { _ in addonBannerModel }
        )
        sut = mockService

        let respondedAddonBannerModel = try! await mockService.getAddonBannerModel(source: .insurances)
        assert(respondedAddonBannerModel == addonBannerModel)
    }
}
