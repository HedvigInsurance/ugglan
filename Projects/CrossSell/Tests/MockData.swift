import hCore

@testable import CrossSell

@MainActor
struct MockData {
    static func createMockCrossSellService(
        fetchCrossSell: @escaping FetchCrossSell = {
            [
                .init(
                    title: "title",
                    description: "description",
                    type: .home
                )
            ]
        }
    ) -> MockCrossSellService {
        let service = MockCrossSellService(
            fetchCrossSell: fetchCrossSell
        )
        Dependencies.shared.add(module: Module { () -> CrossSellClient in service })
        return service
    }
}

enum MockContractError: Error {
    case fetchCrossSells
}

typealias FetchCrossSell = () async throws -> [CrossSell]

class MockCrossSellService: CrossSellClient {
    var events = [Event]()
    var fetchCrossSell: FetchCrossSell

    enum Event {
        case getCrossSell
    }

    init(
        fetchCrossSell: @escaping FetchCrossSell
    ) {
        self.fetchCrossSell = fetchCrossSell
    }

    func getCrossSell() async throws -> [CrossSell] {
        events.append(.getCrossSell)
        let data = try await fetchCrossSell()
        return data
    }
}
