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
        fetchCrossSell: @escaping FetchCrossSell = {
            [
                .init(
                    title: "title",
                    description: "description",
                    type: .home
                )
            ]
        },
        fetchAddonBanner: @escaping FetchAddonBanner = {
            nil
        }
    ) -> MockContractService {
        let service = MockContractService(
            fetchContracts: fetchContracts,
            fetchCrossSell: fetchCrossSell,
            fetchAddonBanner: fetchAddonBanner
        )
        Dependencies.shared.add(module: Module { () -> FetchContractsClient in service })
        return service
    }
}

enum MockContractError: Error {
    case fetchContracts
    case fetchCrossSells
}

typealias FetchContracts = () async throws -> ContractsStack
typealias FetchCrossSell = () async throws -> [CrossSell]
typealias FetchAddonBanner = () async throws -> AddonBannerModel?

class MockContractService: FetchContractsClient {
    var events = [Event]()
    var fetchContracts: FetchContracts
    var fetchCrossSell: FetchCrossSell
    var fetchAddonBanner: FetchAddonBanner

    enum Event {
        case getContracts
        case getCrossSell
        case getAddonBanner
    }

    init(
        fetchContracts: @escaping FetchContracts,
        fetchCrossSell: @escaping FetchCrossSell,
        fetchAddonBanner: @escaping FetchAddonBanner
    ) {
        self.fetchContracts = fetchContracts
        self.fetchCrossSell = fetchCrossSell
        self.fetchAddonBanner = fetchAddonBanner
    }

    func getContracts() async throws -> ContractsStack {
        events.append(.getContracts)
        let data = try await fetchContracts()
        return data
    }

    func getCrossSell() async throws -> [CrossSell] {
        events.append(.getCrossSell)
        let data = try await fetchCrossSell()
        return data
    }

    func getAddonBannerModel(source: AddonSource) async throws -> AddonBannerModel? {
        events.append(.getAddonBanner)
        let data = try await fetchAddonBanner()
        return data
    }

}
