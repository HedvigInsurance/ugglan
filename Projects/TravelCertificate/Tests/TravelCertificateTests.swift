import Addons
import Foundation
import TestDependencies
import Testing
import hCore

@testable import TravelCertificate

@Suite(.serialized)
@MainActor
final class TravelCertificateTests {
    // Serialized: every test registers and removes TravelInsuranceClient in Dependencies.shared.
    private weak var sut: MockTravelInsuranceService?

    @Test
    func listViewModelSuccess() async {
        let specifications: [TravelInsuranceContractSpecification] = [
            .init(
                contractId: "contractId",
                displayName: "",
                exposureDisplayName: "",
                minStartDate: Date(),
                maxStartDate: Date(),
                maxDuration: 3,
                email: nil,
                fullName: "First Last"
            )
        ]

        // Scoped so mockService is released before expectServiceReleased() runs.
        await recordingErrors {
            let mockService = MockData.createMockTravelInsuranceService(
                fetchSpecifications: { specifications }
            )
            sut = mockService

            let respondedList = try await mockService.getSpecifications()
            #expect(respondedList == specifications)
        }

        await expectServiceReleased()
    }

    @Test
    func submitForm() async {
        let dto: TravelInsuranceFormDTO = .init(
            contractId: "contractId",
            startDate: "2024-08-08",
            isMemberIncluded: true,
            coInsured: [],
            email: "email@email.com"
        )

        let urlPath = URL(string: dto.contractId)

        await recordingErrors {
            let mockService = MockData.createMockTravelInsuranceService(
                submit: { dto in
                    if let urlPath = URL(string: dto.contractId) {
                        return urlPath
                    }
                    throw TravelInsuranceError.missingURL
                }
            )
            sut = mockService

            let respondedUrl = try await mockService.submitForm(dto: dto)
            #expect(respondedUrl == urlPath)
        }

        await expectServiceReleased()
    }

    @Test
    func listSuccess() async {
        let list: [TravelCertificateModel] = [
            .init(
                id: "id",
                date: Date(),
                valid: true,
                url: URL(string: "https://www.hedvig.com")
            )!
        ]
        .compactMap { $0 }

        do {
            let mockService = MockData.createMockTravelInsuranceService(
                fetchList: { (list, true, nil) }
            )
            sut = mockService

            let model = TravelCertificatesListScreenViewModel()
            await model.fetchTravelCertificateList()

            #expect(model.list == list)
        }

        await expectServiceReleased()
    }

    @Test
    func listWithBannerSuccess() async {
        let list: [TravelCertificateModel] = [
            .init(
                id: "id",
                date: Date(),
                valid: true,
                url: URL(string: "https://www.hedvig.com")
            )!
        ]
        .compactMap { $0 }

        let testBanner = AddonBanner(
            contractIds: ["contractId"],
            displayTitle: "Travel Plus",
            displayDescription: "Extended travel insurance with extra coverage",
            badges: ["Popular"],
            addonType: .travelPlus
        )

        do {
            let mockService = MockData.createMockTravelInsuranceService(
                fetchList: { (list, true, testBanner) }
            )
            sut = mockService

            let model = TravelCertificatesListScreenViewModel()
            await model.fetchTravelCertificateList()

            #expect(model.list == list)
            #expect(model.addonBanner == testBanner)
        }

        await expectServiceReleased()
    }

    // Not deinit: this has to suspend before it reads sut.
    private func expectServiceReleased() async {
        Dependencies.shared.remove(for: TravelInsuranceClient.self)
        try? await Task.sleep(for: .seconds(0.0000001))
        #expect(sut == nil, "the mock service must not outlive its dependency registration")
    }
}
