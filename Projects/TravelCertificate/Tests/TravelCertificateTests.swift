import XCTest

@testable import TravelCertificate

final class TravelCertificateTests: XCTestCase {
    weak var sut: MockTravelInsuranceService?

    override func setUp() {
        super.setUp()
    }

    override func tearDownWithError() throws {
        XCTAssertNil(sut)
    }

    func testSpecificationsSuccess() async {
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

        let model = await ListScreen(infoButtonPlacement: .automatic)
        await model.createNewPressed()
        //        assert(model.vm.list == specifications)
        self.sut = mockService
    }

    func testListSuccess() async {
        let list: [TravelCertificateModel] = [
            .init(
                id: "id",
                date: Date(),
                valid: true,
                url: nil
            )!
        ]

        let mockService = MockData.createMockTravelInsuranceService(
            fetchList: { return (list, true) }
        )

        let model = ListScreenViewModel()
        await model.fetchTravelCertificateList()

        assert(model.list == list)
        self.sut = mockService
    }
}
