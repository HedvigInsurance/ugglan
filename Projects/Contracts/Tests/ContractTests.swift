import Addons
import TestDependencies
import Testing
import hCore

@testable import Contracts

extension ContractsDependencySuite {
    @MainActor
    final class ContractsTests {
        private weak var sut: MockContractService?

        @Test
        func getContractsSuccess() async {
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
                        exposureDisplayNameShort: "exposure display name short",
                        masterInceptionDate: "2024-04-05",
                        terminationDate: nil,
                        supportsAddressChange: true,
                        supportsCoInsured: true,
                        supportsCoOwners: false,
                        supportsTravelCertificate: true,
                        supportsChangeTier: true,
                        supportsTermination: true,
                        upcomingChangedAgreement: nil,
                        upcomingRenewal: nil,
                        firstName: "first",
                        lastName: "last",
                        ssn: nil,
                        typeOfContract: .seHouse,
                        coInsured: [],
                        coOwners: [],
                        missingPetChipId: false,
                    )
                ],
                pendingContracts: [],
                terminatedContracts: []
            )

            // Scoped so mockService is released before expectServiceReleased() runs.
            await recordingErrors {
                let mockService = MockData.createMockContractsService(
                    fetchContracts: { contractsStack }
                )
                sut = mockService

                let respondedContracts = try await mockService.fetchContracts()
                #expect(respondedContracts.activeContracts == contractsStack.activeContracts)
                #expect(respondedContracts.pendingContracts == contractsStack.pendingContracts)
                #expect(respondedContracts.terminatedContracts == contractsStack.terminatedContracts)
            }

            await expectServiceReleased()
        }

        @Test
        func getAddonBannersSuccess() async {
            let testBanner = AddonBanner(
                contractIds: ["contractId"],
                displayTitle: "Travel Plus",
                displayDescription: "Extended travel insurance with extra coverage",
                badges: ["Popular"],
                addonType: .travelPlus
            )

            await recordingErrors {
                let mockService = MockData.createMockContractsService(
                    fetchAddonBanners: { [testBanner] }
                )
                sut = mockService

                let respondedBanners = try await mockService.getAddonBanners(source: .insurances)
                #expect(respondedBanners == [testBanner])
            }

            await expectServiceReleased()
        }

        // Not deinit: this has to suspend before it reads sut.
        private func expectServiceReleased() async {
            Dependencies.shared.remove(for: FetchContractsClient.self)
            await delay(0.0000001)
            #expect(sut == nil, "the mock service must not outlive its dependency registration")
        }
    }
}
