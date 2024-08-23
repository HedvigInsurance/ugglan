import Presentation
import XCTest

@testable import Contracts

final class ContractStoreTests: XCTestCase {
    weak var store: ContractStore?

    override func setUp() {
        super.setUp()
        globalPresentableStoreContainer.deletePersistanceContainer()
    }

    override func tearDown() async throws {
        await waitUntil(description: "Store deinited successfully") {
            self.store == nil
        }
    }

    func testFetchCrossSalesSuccess() async {
        let crossSellData: [CrossSell] = [
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

        let mockService = MockData.createMockContractsService(
            fetchCrossSell: { crossSellData }
        )

        let store = ContractStore()
        self.store = store
        await store.sendAsync(.fetchCrossSale)
        await waitUntil(description: "loading state") {
            store.loadingSignal.value[.fetchCrossSell] == nil
        }

        assert(store.state.crossSells == crossSellData)
        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getCrossSell)
    }

    func testFetchCrossSalesFailure() async {
        let mockService = MockData.createMockContractsService(
            fetchCrossSell: { throw MockContractError.fetchCrossSells }
        )

        let store = ContractStore()
        self.store = store
        await store.sendAsync(.fetchCrossSale)
        await waitUntil(description: "loading state") {
            store.loadingSignal.value[.fetchCrossSell] != nil
        }

        assert(store.state.crossSells.isEmpty)
        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getCrossSell)
    }

    func testFetchContractsSuccess() async {
        let contractsStack: ContractsStack = .init(
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
                            displayName: "display name"
                        )
                    ),
                    exposureDisplayName: "exposure display name",
                    masterInceptionDate: "2024-04-05",
                    terminationDate: nil,
                    supportsAddressChange: true,
                    supportsCoInsured: true,
                    supportsTravelCertificate: true,
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

        let store = ContractStore()
        self.store = store
        await store.sendAsync(.fetchContracts)
        await waitUntil(description: "loading state") {
            store.loadingSignal.value[.fetchContracts] == nil
        }

        assert(store.state.activeContracts == contractsStack.activeContracts)
        assert(store.state.pendingContracts == contractsStack.pendingContracts)
        assert(store.state.terminatedContracts == contractsStack.terminatedContracts)
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
            store.loadingSignal.value[.fetchContracts] != nil
        }

        assert(store.state.activeContracts.isEmpty)
        assert(store.state.pendingContracts.isEmpty)
        assert(store.state.terminatedContracts.isEmpty)
        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getContracts)
    }
}

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
