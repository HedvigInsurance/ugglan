@preconcurrency import XCTest
import hCore

@testable import CrossSell

@MainActor
final class CrossSellTests: XCTestCase {
    weak var sut: MockCrossSellService?

    override func tearDown() async throws {
        Dependencies.shared.remove(for: CrossSellClient.self)
        try await Task.sleep(nanoseconds: 100)

        XCTAssertNil(sut)
    }

    func testGetCrossSellSuccess() async {
        let crossSell: [CrossSell] = [
            .init(
                title: "car",
                description: "description",
                type: .car
            ),
            .init(
                title: "pet",
                description: "description",
                type: .pet
            ),
        ]

        let mockService = MockData.createMockCrossSellService(
            fetchCrossSell: { crossSell }
        )
        self.sut = mockService

        let respondedCrossSell = try! await mockService.fetchCrossSell()
        assert(respondedCrossSell == crossSell)
    }
}
