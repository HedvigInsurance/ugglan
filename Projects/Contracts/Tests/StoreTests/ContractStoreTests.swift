import PresentableStore
@preconcurrency import XCTest

@testable import Contracts

@MainActor
final class ContractStoreTests: XCTestCase {
    weak var store: ContractStore?

    override func setUp() async throws {
        try await super.setUp()
        globalPresentableStoreContainer.deletePersistanceContainer()
    }
    @MainActor
    override func tearDown() async throws {
        try await super.tearDown()
        await waitUntil(description: "Store deinit") {
            self.store == nil
        }
    }

    func testFetchCrossSalesSuccess() async {
        let mockService = MockData.createMockContractsService(
            fetchCrossSell: { CrossSell.getDefault }
        )
        let store = ContractStore()
        self.store = store
        await store.sendAsync(.fetchCrossSale)
        await waitUntil(description: "loading state") {
            store.loadingState[.fetchCrossSell] == nil && store.state.crossSells == CrossSell.getDefault
        }

        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getCrossSell)
    }

    func testFetchCrossSalesFailure() async throws {
        let mockService = MockData.createMockContractsService(
            fetchCrossSell: { throw MockContractError.fetchCrossSells }
        )

        let store = ContractStore()
        self.store = store
        await store.sendAsync(.fetchCrossSale)
        try await Task.sleep(nanoseconds: 5 * 100_000_000)
        assert(store.loadingState[.fetchCrossSell] != nil)
        assert(store.state.crossSells.isEmpty)
        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getCrossSell)
    }

    func testFetchContractsSuccess() async {
        let mockService = MockData.createMockContractsService(
            fetchContracts: { ContractsStack.getDefault }
        )
        let store = ContractStore()
        self.store = store
        await store.sendAsync(.fetchContracts)
        await waitUntil(description: "loading state") {
            store.loadingState[.fetchContracts] == nil
        }

        assert(store.state.activeContracts == ContractsStack.getDefault.activeContracts)
        assert(store.state.pendingContracts == ContractsStack.getDefault.pendingContracts)
        assert(store.state.terminatedContracts == ContractsStack.getDefault.terminatedContracts)
        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getContracts)
    }

    func testFetchContractsFailure() async {
        let mockService = MockData.createMockContractsService(
            fetchContracts: { throw MockContractError.fetchContracts }
        )

        let store = ContractStore()
        self.store = store
        await store.sendAsync(.fetchContracts)
        await waitUntil(description: "loading state") {
            store.loadingState[.fetchContracts] != nil
        }

        assert(store.state.activeContracts.isEmpty)
        assert(store.state.pendingContracts.isEmpty)
        assert(store.state.terminatedContracts.isEmpty)
        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getContracts)
    }

    func testFetchSuccess() async {
        let mockService = MockData.createMockContractsService(
            fetchContracts: { ContractsStack.getDefault },
            fetchCrossSell: { CrossSell.getDefault }
        )
        let store = ContractStore()
        self.store = store
        await store.sendAsync(.fetch)
        await waitUntil(description: "loading state") {
            store.loadingState[.fetchContracts] == nil && store.loadingState[.fetchCrossSell] == nil
        }

        assert(store.state.activeContracts == ContractsStack.getDefault.activeContracts)
        assert(store.state.pendingContracts == ContractsStack.getDefault.pendingContracts)
        assert(store.state.terminatedContracts == ContractsStack.getDefault.terminatedContracts)
        assert(store.state.crossSells == CrossSell.getDefault)
        assert(mockService.events.count == 2)
        assert(mockService.events.contains(.getContracts))
        assert(mockService.events.contains(.getCrossSell))
    }

}

@MainActor
extension ContractsStack {
    fileprivate static let getDefault: ContractsStack = .init(
        activeContracts: [
            .init(
                id: "id",
                currentAgreement: .init(
                    premium: .init(amount: "234", currency: "SEK"),
                    displayItems: [],
                    productVariant: .init(
                        termsVersion: "",
                        typeOfContract: "",
                        partner: nil,
                        perils: [],
                        insurableLimits: [],
                        documents: [],
                        displayName: "display name",
                        displayNameTier: "standard",
                        tierDescription: "tier description"
                    )
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
}

@MainActor
extension CrossSell {
    fileprivate static let getDefault: [CrossSell] = [
        .init(
            title: "car",
            description: "description",
            imageURL: URL(string: "https://hedvig.com")!,
            blurHash: "",
            typeOfContract: "",
            type: .car
        ),
        .init(
            title: "home",
            description: "description",
            imageURL: URL(string: "https://hedvig.com")!,
            blurHash: "",
            typeOfContract: "",
            type: .home
        ),
    ]
}

@MainActor
extension XCTestCase {
    public func waitUntil(description: String, closure: @escaping () -> Bool) async {
        let exc = expectation(description: description)
        if closure() {
            exc.fulfill()
        } else {
            try! await Task.sleep(nanoseconds: 100_000_000)
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
