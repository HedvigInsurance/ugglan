import AppStateContainer
import TestDependencies
import Testing
import hCore

@testable import Contracts

extension ContractsDependencySuite {
    @MainActor
    final class ContractStoreTests {
        private weak var store: ContractStore?

        init() {
            globalAppStateContainer.clearPersistence()
        }

        @Test
        func fetchContractsSuccess() async {
            // Scoped so the store is released before expectStoreReleased() waits for it.
            do {
                let mockService = MockData.createMockContractsService(
                    fetchContracts: { ContractsStack.getDefault }
                )
                let store = ContractStore()
                self.store = store
                await store.fetchContracts()
                #expect(store.activeContracts == ContractsStack.getDefault.activeContracts)
                #expect(store.pendingContracts == ContractsStack.getDefault.pendingContracts)
                #expect(store.terminatedContracts == ContractsStack.getDefault.terminatedContracts)
                #expect(store.fetchContractsError == nil)
                #expect(mockService.events.count == 1)
                #expect(mockService.events.first == .getContracts)
            }

            await expectStoreReleased()
        }

        @Test
        func fetchContractsFailure() async {
            do {
                let mockService = MockData.createMockContractsService(
                    fetchContracts: { throw MockContractError.fetchContracts }
                )

                let store = ContractStore()
                self.store = store
                await store.fetchContracts()

                #expect(store.activeContracts.isEmpty)
                #expect(store.pendingContracts.isEmpty)
                #expect(store.terminatedContracts.isEmpty)
                #expect(store.fetchContractsError != nil)
                #expect(mockService.events.count == 1)
                #expect(mockService.events.first == .getContracts)
            }

            await expectStoreReleased()
        }

        // Not deinit: these steps must run after the test body has dropped its store reference.
        private func expectStoreReleased() async {
            await waitUntil(description: "Store deinit") {
                self.store == nil
            }
            // Removed only once the store is gone, so its @Inject client can't resolve after removal.
            Dependencies.shared.remove(for: FetchContractsClient.self)
            globalAppStateContainer.clearPersistence()
        }
    }
}

@MainActor
extension ContractsStack {
    fileprivate static let getDefault: ContractsStack = .init(
        activeContracts: [
            .init(
                id: "id",
                currentAgreement: .init(
                    id: "agreementId",
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
}
