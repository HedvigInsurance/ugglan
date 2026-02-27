import Addons
@preconcurrency import XCTest
import hCore

@testable import Contracts

@MainActor
final class ContractsTests: XCTestCase {
    weak var sut: MockContractService?

    override func tearDown() async throws {
        Dependencies.shared.remove(for: FetchContractsClient.self)
        try await Task.sleep(seconds: 0.0000001)

        XCTAssertNil(sut)
    }

    func testGetContractsSuccess() async throws {
        let contractsStack: ContractsStack = .init(
            activeContracts: [
                .init(
                    id: "id",
                    currentAgreement: .init(
                        id: "id",
                        basePremium: .sek(234),
                        itemCost: .init(premium: .init(gross: .sek(234), net: .sek(234)), discounts: []),
                        displayItems: [],
                        productVariant: .init(
                            termsVersion: "",
                            typeOfContract: "",
                            perils: [],
                            insurableLimits: [],
                            documents: [],
                            displayName: "display name",
                            displayNameTier: "standard",
                            tierDescription: "tier description"
                        ),
                        addonVariant: []
                    ),
                    exposureDisplayName: "exposure display name",
                    masterInceptionDate: "2024-04-05",
                    terminationDate: nil,
                    supportsAddressChange: true,
                    supportsCoInsured: true,
                    supportsTravelCertificate: true,
                    supportsChangeTier: true,
                    upcomingChangedAgreement: nil,
                    upcomingRenewal: nil,
                    firstName: "first",
                    lastName: "last",
                    ssn: nil,
                    typeOfContract: .seHouse,
                    coInsured: []
                )
            ],
            pendingContracts: [],
            terminatedContracts: []
        )

        let mockService = MockData.createMockContractsService(
            fetchContracts: { contractsStack }
        )
        sut = mockService

        let respondedContracts = try await mockService.fetchContracts()
        assert(respondedContracts.activeContracts == contractsStack.activeContracts)
        assert(respondedContracts.pendingContracts == contractsStack.pendingContracts)
        assert(respondedContracts.terminatedContracts == contractsStack.terminatedContracts)
    }

    func testGetAddonBannersSuccess() async throws {
        let testBanner = AddonBanner(
            contractIds: ["contractId"],
            titleDisplayName: "Travel Plus",
            descriptionDisplayName: "Extended travel insurance with extra coverage",
            badges: ["Popular"],
            addonType: .travelPlus
        )

        let mockService = MockData.createMockContractsService(
            fetchAddonBanners: { [testBanner] }
        )
        sut = mockService

        let respondedBanners = try await mockService.getAddonBanners(source: .insurances)
        assert(respondedBanners == [testBanner])
    }
}
