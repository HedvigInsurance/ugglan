import AppStateContainer
import XCTest

@testable import Contracts

@MainActor
final class ContractStoreTests: XCTestCase {
    weak var store: ContractStore?

    override func setUp() async throws {
        try await super.setUp()
        globalAppStateContainer.clearPersistence()
    }

    @MainActor
    override func tearDown() async throws {
        try await super.tearDown()
        await waitUntil(description: "Store deinit") {
            self.store == nil
        }
        globalAppStateContainer.clearPersistence()
    }

    func testFetchContractsSuccess() async {
        let mockService = MockData.createMockContractsService(
            fetchContracts: { ContractsStack.getDefault }
        )
        let store = ContractStore()
        self.store = store
        await store.fetchContracts()
        assert(store.activeContracts == ContractsStack.getDefault.activeContracts)
        assert(store.pendingContracts == ContractsStack.getDefault.pendingContracts)
        assert(store.terminatedContracts == ContractsStack.getDefault.terminatedContracts)
        assert(store.fetchContractsError == nil)
        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getContracts)
    }

    func testFetchContractsFailure() async {
        let mockService = MockData.createMockContractsService(
            fetchContracts: { throw MockContractError.fetchContracts }
        )

        let store = ContractStore()
        self.store = store
        await store.fetchContracts()

        assert(store.activeContracts.isEmpty)
        assert(store.pendingContracts.isEmpty)
        assert(store.terminatedContracts.isEmpty)
        assert(store.fetchContractsError != nil)
        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getContracts)
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

@MainActor
extension XCTestCase {
    public func waitUntil(description: String, closure: @escaping () -> Bool) async {
        let exc = expectation(description: description)
        if closure() {
            exc.fulfill()
        } else {
            try! await Task.sleep(seconds: 0.1)
            Task {
                await self.waitUntil(description: description, closure: closure)
                if closure() {
                    exc.fulfill()
                }
            }
        }
        await fulfillment(of: [exc], timeout: 2)
    }
}
