import XCTest
import hCore

@testable import TravelCertificate

final class TravelCertificateTests: XCTestCase {
    weak var sut: MockTravelInsuranceService?

    override func setUp() {
        super.setUp()
        sut = nil
    }

    override func tearDown() async throws {
        //added this to remove dependency so we can test if the sut is nil
        Dependencies.shared.remove(for: TravelInsuranceClient.self)
        try await Task.sleep(nanoseconds: 100)

        XCTAssertNil(sut)
    }

    func testListViewModelSuccess() async {
        let specifications: [TravelInsuranceContractSpecification] = [
            .init(
                contractId: "contractId",
                minStartDate: Date(),
                maxStartDate: Date(),
                numberOfCoInsured: 2,
                maxDuration: 3,
                street: "Street name",
                email: nil,
                fullName: "First Last"
            )
        ]

        let mockService = MockData.createMockTravelInsuranceService(
            fetchSpecifications: { return specifications }
        )
        self.sut = mockService

        let respondedList = try! await mockService.getSpecifications()
        assert(respondedList == specifications)
    }

    func testListSuccess() async {
        let list: [TravelCertificateModel] = [
            .init(
                id: "id",
                date: Date(),
                valid: true,
                url: URL(string: "https://www.hedvig.com")
            )!
        ]
        .compactMap({ $0 })

        let mockService = MockData.createMockTravelInsuranceService(
            fetchList: { return (list, true) }
        )
        self.sut = mockService

        let model = ListScreenViewModel()
        await model.fetchTravelCertificateList()

        assert(model.list == list)
    }
}
