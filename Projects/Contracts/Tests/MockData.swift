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
                    imageURL: URL(string: "url")!,
                    blurHash: "",
                    typeOfContract: "",
                    type: .home
                )
            ]
        }
    ) -> MockContractService {
        let service = MockContractService(
            fetchContracts: fetchContracts,
            fetchCrossSell: fetchCrossSell
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

class MockContractService: FetchContractsClient {
    var events = [Event]()
    var fetchContracts: FetchContracts
    var fetchCrossSell: FetchCrossSell

    enum Event {
        case getContracts
        case getCrossSell
    }

    init(
        fetchContracts: @escaping FetchContracts,
        fetchCrossSell: @escaping FetchCrossSell
    ) {
        self.fetchContracts = fetchContracts
        self.fetchCrossSell = fetchCrossSell
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
}
