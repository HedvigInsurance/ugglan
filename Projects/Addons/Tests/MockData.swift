import Foundation
import hCore

@testable import Addons

@MainActor
struct MockData {
    @discardableResult
    static func createMockAddonsService(
        fetchAddon: @escaping FetchAddon = { contractId in
            return .init(
                titleDisplayName: "title",
                description: "description",
                activationDate: Date(),
                quotes: []
            )
        },
        addonSubmit: @escaping AddonSubmit = { quoteId, addonId in
            return .init()
        }
    ) -> MockAddonsService {
        let service = MockAddonsService(
            fetchAddon: fetchAddon,
            addonSubmit: addonSubmit
        )
        Dependencies.shared.add(module: Module { () -> AddonsClient in service })
        return service
    }
}

typealias FetchAddon = (String) async throws -> AddonOffer
typealias AddonSubmit = (String, String) async throws -> Date?

class MockAddonsService: AddonsClient {
    var events = [Event]()

    var fetchAddon: FetchAddon
    var addonSubmit: AddonSubmit

    enum Event {
        case getAddon
        case submitAddon
    }

    init(
        fetchAddon: @escaping FetchAddon,
        addonSubmit: @escaping AddonSubmit
    ) {
        self.fetchAddon = fetchAddon
        self.addonSubmit = addonSubmit
    }

    func getAddon(contractId: String) async throws -> AddonOffer {
        events.append(.getAddon)
        let data = try await fetchAddon(contractId)
        return data
    }

    func submitAddon(quoteId: String, addonId: String) async throws -> Date? {
        events.append(.submitAddon)
        let data = try await addonSubmit(quoteId, addonId)
        return data
    }
}
