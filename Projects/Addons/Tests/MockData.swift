import Foundation
import hCore

@testable import Addons

@MainActor
struct MockData {
    @discardableResult
    static func createMockAddonsService(
        fetchAddon: @escaping FetchAddon = {
            return .init(
                id: "id",
                title: "title",
                subTitle: "subTitle",
                tag: "tag",
                informationText: "information text",
                options: []
            )
        },
        fetchContract: @escaping FetchContract = { contractId in
            .init(
                contractId: contractId,
                contractName: "contract name",
                displayItems: [],
                documents: [],
                insurableLimits: [],
                typeOfContract: nil,
                activationDate: Date(),
                currentPremium: .init(amount: "220", currency: "SEK")
            )
        },
        addonSubmit: @escaping AddonSubmit = {}
    ) -> MockAddonsService {
        let service = MockAddonsService(
            fetchAddon: fetchAddon,
            fetchContract: fetchContract,
            addonSubmit: addonSubmit
        )
        Dependencies.shared.add(module: Module { () -> AddonsClient in service })
        return service
    }
}

typealias FetchAddon = () async throws -> AddonModel
typealias FetchContract = (String) async throws -> AddonContract
typealias AddonSubmit = () async throws -> Void

class MockAddonsService: AddonsClient {
    var events = [Event]()

    var fetchAddon: FetchAddon
    var fetchContract: FetchContract
    var addonSubmit: AddonSubmit

    enum Event {
        case getAddon
        case getContract
        case submitAddon
    }

    init(
        fetchAddon: @escaping FetchAddon,
        fetchContract: @escaping FetchContract,
        addonSubmit: @escaping AddonSubmit
    ) {
        self.fetchAddon = fetchAddon
        self.fetchContract = fetchContract
        self.addonSubmit = addonSubmit
    }

    func getAddon() async throws -> AddonModel {
        events.append(.getAddon)
        let data = try await fetchAddon()
        return data
    }

    func getContract(contractId: String) async throws -> AddonContract {
        events.append(.getContract)
        let data = try await fetchContract(contractId)
        return data
    }

    func submitAddon() async throws {
        events.append(.submitAddon)
        try await addonSubmit()
    }
}
