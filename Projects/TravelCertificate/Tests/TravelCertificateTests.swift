@preconcurrency import XCTest
import hCore

@testable import TravelCertificate

@MainActor
final class TravelCertificateTests: XCTestCase {
    weak var sut: MockTravelInsuranceService?

    override func setUp() async throws {
        try await super.setUp()
        sut = nil
    }

    override func tearDown() async throws {
        Dependencies.shared.remove(for: TravelInsuranceClient.self)
        try await Task.sleep(nanoseconds: 100)

        XCTAssertNil(sut)
    }

    func testListViewModelSuccess() async {
        let specifications: [TravelInsuranceContractSpecification] = [
            .init(
                contractId: "contractId",
                displayName: "",
                exposureDisplayName: "",
                minStartDate: Date(),
                maxStartDate: Date(),
                numberOfCoInsured: 2,
                maxDuration: 3,
                email: nil,
                fullName: "First Last"
            )
        ]

        let mockService = MockData.createMockTravelInsuranceService(
            fetchSpecifications: { specifications }
        )
        sut = mockService

        let respondedList = try! await mockService.getSpecifications()
        assert(respondedList == specifications)
    }

    func testSubmitForm() async {
        let dto: TravelInsuranceFormDTO = .init(
            contractId: "contractId",
            startDate: "2024-08-08",
            isMemberIncluded: true,
            coInsured: [],
            email: "email@email.com"
        )

        let urlPath = URL(string: dto.contractId)

        let mockService = MockData.createMockTravelInsuranceService(
            submit: { dto in
                if let urlPath = URL(string: dto.contractId) {
                    return urlPath
                }
                throw TravelInsuranceError.missingURL
            }
        )
        sut = mockService

        let respondedUrl = try! await mockService.submitForm(dto: dto)
        assert(respondedUrl == urlPath)
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
        .compactMap { $0 }

        let mockService = MockData.createMockTravelInsuranceService(
            fetchList: { (list, true, nil) }
        )
        sut = mockService

        let model = ListScreenViewModel()
        await model.fetchTravelCertificateList()

        assert(model.list == list)
    }
}
