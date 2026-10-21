import AppStateContainer
import TestDependencies
import Testing
import hCore

@testable import Claims
@testable import Contracts
@testable import Profile

extension ProfileDependencySuite {
    @MainActor
    final class DeleteAccountViewModelTests {
        private weak var sut: MockProfileService?
        private weak var claimsStore: ClaimsStore?
        private weak var contractStore: ContractStore?

        init() {
            globalAppStateContainer.clearPersistence()
        }

        // Test bodies are scoped; the stores are held only by the VM's RunLoop.main sinks, hence the wait.
        private func expectReleased() async {
            Dependencies.shared.remove(for: ProfileClient.self)
            await delay(0.0000001)
            #expect(sut == nil, "the mock service must not outlive its dependency registration")
            await waitUntil(description: "the stores must not outlive the view model that read them") {
                self.claimsStore == nil && self.contractStore == nil
            }
        }

        @Test
        func deleteAccountViewModelSuccess() async {
            do {
                let mockService = MockData.createMockProfileService(deleteRequest: {})
                sut = mockService

                let claimsStore = ClaimsStore()
                self.claimsStore = claimsStore
                claimsStore.activeClaims = [
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
                    )
                ]

                let contractStore = ContractStore()
                self.contractStore = contractStore
                contractStore.activeContracts = [
                    .init(
                        id: "contractId",
                        currentAgreement: .init(
                            id: "id",
                            certificateUrl: nil,
                            agreementDate: .init(activeFrom: nil, activeTo: nil),
                            basePremium: .init(amount: "220", currency: "SEK"),
                            itemCost: nil,
                            displayItems: [],
                            productVariant: .init(
                                termsVersion: "",
                                typeOfContract: "",
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
                        exposureDisplayNameShort: "exposure display name short",
                        masterInceptionDate: "2024-04-17",
                        terminationDate: nil,
                        supportsAddressChange: true,
                        supportsCoInsured: true,
                        supportsCoOwners: false,
                        supportsTravelCertificate: true,
                        supportsChangeTier: true,
                        supportsTermination: true,
                        upcomingChangedAgreement: nil,
                        upcomingRenewal: nil,
                        firstName: "first name",
                        lastName: "last name",
                        ssn: nil,
                        typeOfContract: .seApartmentBrf,
                        coInsured: [],
                        coOwners: [],
                        missingPetChipId: false,
                    )
                ]

                let model = DeleteAccountViewModel(
                    claimsStore: claimsStore,
                    contractsStore: contractStore
                )

                #expect(model.hasActiveClaims == true)
                #expect(model.hasActiveContracts == true)
            }

            await expectReleased()
        }

        @Test
        func deleteAccountViewModelFailure() async {
            do {
                let mockService = MockData.createMockProfileService(deleteRequest: {
                    throw ProfileError.error(message: "error")
                })
                sut = mockService

                let claimsStore = ClaimsStore()
                self.claimsStore = claimsStore

                let contractStore = ContractStore()
                self.contractStore = contractStore

                let model = DeleteAccountViewModel(
                    claimsStore: claimsStore,
                    contractsStore: contractStore
                )

                #expect(model.hasActiveClaims == false)
                #expect(model.hasActiveContracts == false)
            }

            await expectReleased()
        }
    }
}
