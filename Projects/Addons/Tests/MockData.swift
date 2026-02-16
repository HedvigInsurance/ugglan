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
        fetchAddonOfferCost: @escaping FetchAddonOfferCost = { _, _ in throw AddonsError.somethingWentWrong },
        fetchAddonRemoveOffer: @escaping FetchAddonRemoveOffer = { _ in throw AddonsError.somethingWentWrong },
        confirmAddonRemoval: @escaping ConfirmAddonRemoval = { _, _ in },
        fetchAddonRemoveOfferCost: @escaping FetchAddonRemoveOfferCost = { _, _ in
            throw AddonsError.somethingWentWrong
        }
    ) -> MockAddonsService {
        let service = MockAddonsService(
            fetchAddonOffer: fetchAddonOffer,
            addonsSubmit: addonsSubmit,
            fetchBanners: fetchBanners,
            fetchAddonOfferCost: fetchAddonOfferCost,
            fetchAddonRemoveOffer: fetchAddonRemoveOffer,
            confirmAddonRemoval: confirmAddonRemoval,
            fetchAddonRemoveOfferCost: fetchAddonRemoveOfferCost
        )
        Dependencies.shared.add(module: Module { () -> AddonsClient in service })
        return service
    }
}

typealias FetchAddonOffer = (String) async throws -> AddonOffer
typealias AddonsSubmit = (String, Set<String>) async throws -> Void
typealias FetchBanners = (Addons.AddonSource) async throws -> [Addons.AddonBanner]
typealias FetchAddonOfferCost = (String, Set<String>) async throws -> ItemCost
typealias FetchAddonRemoveOffer = (String) async throws -> AddonRemoveOffer
typealias ConfirmAddonRemoval = (String, Set<String>) async throws -> Void
typealias FetchAddonRemoveOfferCost = (String, Set<String>) async throws -> ItemCost

class MockAddonsService: AddonsClient {
    var events = [Event]()

    var fetchAddon: FetchAddonOffer
    var addonsSubmit: AddonsSubmit
    var fetchBanners: FetchBanners
    var fetchAddonOfferCost: FetchAddonOfferCost
    var fetchAddonRemoveOffer: FetchAddonRemoveOffer
    var confirmAddonRemovalClosure: ConfirmAddonRemoval
    var fetchAddonRemoveOfferCost: FetchAddonRemoveOfferCost

    enum Event {
        case getAddon
        case submitAddon
        case getBanners
        case getAddonOfferCost
        case getAddonRemoveOffer
        case confirmAddonRemoval
        case getAddonRemoveOfferCost
    }

    init(
        fetchAddonOffer: @escaping FetchAddonOffer,
        addonsSubmit: @escaping AddonsSubmit,
        fetchBanners: @escaping FetchBanners,
        fetchAddonOfferCost: @escaping FetchAddonOfferCost,
        fetchAddonRemoveOffer: @escaping FetchAddonRemoveOffer,
        confirmAddonRemoval: @escaping ConfirmAddonRemoval,
        fetchAddonRemoveOfferCost: @escaping FetchAddonRemoveOfferCost
    ) {
        self.fetchAddon = fetchAddonOffer
        self.addonsSubmit = addonsSubmit
        self.fetchBanners = fetchBanners
        self.fetchAddonOfferCost = fetchAddonOfferCost
        self.fetchAddonRemoveOffer = fetchAddonRemoveOffer
        self.confirmAddonRemovalClosure = confirmAddonRemoval
        self.fetchAddonRemoveOfferCost = fetchAddonRemoveOfferCost
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

    func getAddonRemoveOffer(contractId: String) async throws -> AddonRemoveOffer {
        events.append(.getAddonRemoveOffer)
        return try await fetchAddonRemoveOffer(contractId)
    }

    func confirmAddonRemoval(contractId: String, addonIds: Set<String>) async throws {
        events.append(.confirmAddonRemoval)
        try await confirmAddonRemovalClosure(contractId, addonIds)
    }

    func getAddonRemoveOfferCost(contractId: String, addonIds: Set<String>) async throws -> ItemCost {
        events.append(.getAddonRemoveOfferCost)
        return try await fetchAddonRemoveOfferCost(contractId, addonIds)
    }
}
