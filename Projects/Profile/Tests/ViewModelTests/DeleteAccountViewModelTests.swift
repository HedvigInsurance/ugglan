import hCore
import PresentableStore
@preconcurrency import XCTest

@testable import Claims
@testable import Contracts
@testable import Profile

@MainActor
final class DeleteAccountViewModelTests: XCTestCase {
    weak var sut: MockProfileService?
    weak var claimsStore: ClaimsStore?
    weak var contractStore: ContractStore?

    let memberDetails = MemberDetails(
        id: "memberId",
        firstName: "first name",
        lastName: "last name",
        phone: "phone number",
        email: "email",
        hasTravelCertificate: true
    )

    override func setUp() async throws {
        try await super.setUp()
        globalPresentableStoreContainer.deletePersistanceContainer()
        sut = nil
    }

    override func tearDown() async throws {
        Dependencies.shared.remove(for: ProfileClient.self)
        try await Task.sleep(nanoseconds: 100)
        XCTAssertNil(sut)
    }

    func testDeleteAccountViewModelSuccess() async {
        let mockService = MockData.createMockProfileService(deleteRequest: {})
        sut = mockService

        let claimsStore = ClaimsStore()
        self.claimsStore = claimsStore
        await claimsStore.sendAsync(
            .setClaims(claims: [
                .init(
                    id: "id",
                    status: .beingHandled,
                    outcome: .none,
                    submittedAt: nil,
                    signedAudioURL: nil,
                    memberFreeText: nil,
                    payoutAmount: nil,
                    targetFileUploadUri: "",
                    claimType: "claimType",
                    productVariant: nil,
                    conversation: nil,
                    appealInstructionsUrl: nil,
                    isUploadingFilesEnabled: true,
                    showClaimClosedFlow: true,
                    infoText: nil,
                    displayItems: []
                ),
            ])
        )

        let contractStore = ContractStore()
        self.contractStore = contractStore
        await contractStore.sendAsync(
            .setActiveContracts(contracts: [
                .init(
                    id: "contractId",
                    currentAgreement: .init(
                        certificateUrl: nil,
                        activeFrom: nil,
                        activeTo: nil,
                        premium: .init(amount: "220", currency: "SEK"),
                        displayItems: [],
                        productVariant: .init(
                            termsVersion: "",
                            typeOfContract: "",
                            partner: nil,
                            perils: [],
                            insurableLimits: [],
                            documents: [],
                            displayName: "",
                            displayNameTier: "standard",
                            tierDescription: "tier description"
                        ),
                        addonVariant: []
                    ),
                    exposureDisplayName: "display name",
                    masterInceptionDate: "2024-04-17",
                    terminationDate: nil,
                    supportsAddressChange: true,
                    supportsCoInsured: true,
                    supportsTravelCertificate: true,
                    supportsChangeTier: true,
                    upcomingChangedAgreement: nil,
                    upcomingRenewal: nil,
                    firstName: "first name",
                    lastName: "last name",
                    ssn: nil,
                    typeOfContract: .seApartmentBrf,
                    coInsured: []
                ),
            ])
        )

        let model = DeleteAccountViewModel(
            memberDetails: memberDetails,
            claimsStore: claimsStore,
            contractsStore: contractStore
        )

        assert(model.hasActiveClaims == true)
        assert(model.hasActiveContracts == true)
    }

    func testDeleteAccountViewModelFailure() async {
        let mockService = MockData.createMockProfileService(deleteRequest: {
            throw ProfileError.error(message: "error")
        })
        sut = mockService

        let claimsStore = ClaimsStore()
        self.claimsStore = claimsStore

        let contractStore = ContractStore()
        self.contractStore = contractStore

        let model = DeleteAccountViewModel(
            memberDetails: memberDetails,
            claimsStore: claimsStore,
            contractsStore: contractStore
        )

        assert(model.hasActiveClaims == false)
        assert(model.hasActiveContracts == false)
    }
}
