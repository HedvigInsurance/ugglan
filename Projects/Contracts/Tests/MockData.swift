import Addons
import Foundation
import hCore

@testable import Contracts

@MainActor
struct MockData {
    static func createMockContractsService(
        fetchContracts: @escaping FetchContracts = {
            .init(
                activeContracts: [],
                pendingContracts: [],
                terminatedContracts: []
            )
        },
        fetchAddonBanners: @escaping FetchAddonBanners = {
            []
        }
    ) -> MockContractService {
        let service = MockContractService(
            fetchContracts: fetchContracts,
            fetchAddonBanners: fetchAddonBanners
        )
        Dependencies.shared.add(module: Module { () -> FetchContractsClient in service })
        return service
    }
}

enum MockContractError: Error {
    case fetchContracts
}

typealias FetchContracts = () async throws -> ContractsStack
typealias FetchAddonBanners = () async throws -> [AddonBanner]

class MockContractService: FetchContractsClient {
    var events = [Event]()
    var fetchContracts: FetchContracts
    var fetchAddonBanners: FetchAddonBanners

    enum Event {
        case getContracts
        case getAddonBanners
    }

    init(
        fetchContracts: @escaping FetchContracts,
        fetchAddonBanners: @escaping FetchAddonBanners
    ) {
        self.fetchContracts = fetchContracts
        self.fetchAddonBanners = fetchAddonBanners
    }

    func getContracts() async throws -> ContractsStack {
        events.append(.getContracts)
        let data = try await fetchContracts()
        return data
    }

    func getAddonBanners(source: Addons.AddonSource) async throws -> [Addons.AddonBanner] {
        events.append(.getAddonBanners)
        let data = try await fetchAddonBanners()
        return data
    }
}
