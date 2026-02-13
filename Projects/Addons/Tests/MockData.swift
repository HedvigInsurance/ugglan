import Foundation
import hCore

@testable import Addons

@MainActor
struct MockData {
    @discardableResult
    static func createMockAddonsService(
        fetchAddonOffer: @escaping FetchAddonOffer = { _ in throw AddonsError.somethingWentWrong },
        addonsSubmit: @escaping AddonsSubmit = { _, _ in },
        fetchBanners: @escaping FetchBanners = { _ in [] },
        fetchAddonOfferCost: @escaping FetchAddonOfferCost = { _, _ in throw AddonsError.somethingWentWrong }
    ) -> MockAddonsService {
        let service = MockAddonsService(
            fetchAddonOffer: fetchAddonOffer,
            addonsSubmit: addonsSubmit,
            fetchBanners: fetchBanners,
            fetchAddonOfferCost: fetchAddonOfferCost,
        )
        Dependencies.shared.add(module: Module { () -> AddonsClient in service })
        return service
    }
}

typealias FetchAddonOffer = (String) async throws -> AddonOffer
typealias AddonsSubmit = (String, Set<String>) async throws -> Void
typealias FetchBanners = (Addons.AddonSource) async throws -> [Addons.AddonBanner]
typealias FetchAddonOfferCost = (String, Set<String>) async throws -> ItemCost

class MockAddonsService: AddonsClient {
    var events = [Event]()

    var fetchAddon: FetchAddonOffer
    var addonsSubmit: AddonsSubmit
    var fetchBanners: FetchBanners
    var fetchAddonOfferCost: FetchAddonOfferCost

    enum Event {
        case getAddon
        case submitAddon
        case getBanners
        case getAddonOfferCost
    }

    init(
        fetchAddonOffer: @escaping FetchAddonOffer,
        addonsSubmit: @escaping AddonsSubmit,
        fetchBanners: @escaping FetchBanners,
        fetchAddonOfferCost: @escaping FetchAddonOfferCost,
    ) {
        self.fetchAddon = fetchAddonOffer
        self.addonsSubmit = addonsSubmit
        self.fetchBanners = fetchBanners
        self.fetchAddonOfferCost = fetchAddonOfferCost
    }

    func getAddonOffer(contractId: String) async throws -> AddonOffer {
        events.append(.getAddon)
        return try await fetchAddon(contractId)
    }

    func submitAddons(quoteId: String, addonIds: Set<String>) async throws {
        events.append(.submitAddon)
        try await addonsSubmit(quoteId, addonIds)
    }

    func getAddonBanners(source: Addons.AddonSource) async throws -> [Addons.AddonBanner] {
        events.append(.getBanners)
        return try await fetchBanners(source)
    }

    func getAddonOfferCost(quoteId: String, addonIds: Set<String>) async throws -> ItemCost {
        events.append(.getAddonOfferCost)
        return try await fetchAddonOfferCost(quoteId, addonIds)
    }
}
