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
        fetchAddonBanner: @escaping FetchAddonBanner = {
            nil
        }
    ) -> MockContractService {
        let service = MockContractService(
            fetchContracts: fetchContracts,
            fetchAddonBanner: fetchAddonBanner
        )
        Dependencies.shared.add(module: Module { () -> FetchContractsClient in service })
        return service
    }
}

enum MockContractError: Error {
    case fetchContracts
}

typealias FetchContracts = () async throws -> ContractsStack
typealias FetchAddonBanner = () async throws -> AddonBannerModel?

class MockContractService: FetchContractsClient {
    var events = [Event]()
    var fetchContracts: FetchContracts
    var fetchAddonBanner: FetchAddonBanner

    enum Event {
        case getContracts
        case getAddonBanner
    }

    init(
        fetchContracts: @escaping FetchContracts,
        fetchAddonBanner: @escaping FetchAddonBanner
    ) {
        self.fetchContracts = fetchContracts
        self.fetchAddonBanner = fetchAddonBanner
    }

    func getContracts() async throws -> ContractsStack {
        events.append(.getContracts)
        let data = try await fetchContracts()
        return data
    }

    func getAddonBannerModel(source _: AddonSource) async throws -> AddonBannerModel? {
        events.append(.getAddonBanner)
        let data = try await fetchAddonBanner()
        return data
    }
}
