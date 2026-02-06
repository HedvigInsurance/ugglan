import Foundation
import hCore

@testable import Addons

@MainActor
struct MockData {
    @discardableResult
    static func createMockAddonsService(
        fetchAddon: @escaping FetchAddon = { _ in
            .init(
                titleDisplayName: "title",
                description: "description",
                activationDate: Date(),
                currentAddon: nil,
                quotes: []
            )
        },
        addonSubmit: @escaping AddonSubmit = { _, _ in
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
typealias AddonSubmit = (String, String) async throws -> Void

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

    func submitAddon(quoteId: String, addonId: String) async throws {
        events.append(.submitAddon)
        try await addonSubmit(quoteId, addonId)
    }

    func getAddonOffer(contractId: String) async throws -> Addons.AddonOffer {
        throw NSError(domain: "test", code: 0)
    }

    func submitAddons(quoteId: String, addonIds: Set<String>) async throws {
    }
}
