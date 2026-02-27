import Addons
import hCore

@testable import CrossSell

@MainActor
struct MockData {
    static func createMockCrossSellService(
        fetchAddonBanners: @escaping FetchAddonBanners = { _ in
            [
                .init(
                    contractIds: ["contractId"],
                    titleDisplayName: "title",
                    descriptionDisplayName: "description",
                    badges: [],
                    addonType: .travelPlus
                )
            ]
        },
        fetchCrossSell: @escaping FetchCrossSell = { _ in
            .init(
                recommended: nil,
                others: [],
                discountAvailable: true
            )
        }
    ) -> MockCrossSellService {
        let service = MockCrossSellService(
            fetchCrossSell: fetchCrossSell,
            fetchAddonBanners: fetchAddonBanners
        )
        Dependencies.shared.add(module: Module { () -> CrossSellClient in service })
        return service
    }
}

enum MockContractError: Error {
    case fetchCrossSells
    case fetchAddonBanners
}

typealias FetchCrossSell = (CrossSellSource) async throws -> CrossSells
typealias FetchAddonBanners = (AddonSource) async throws -> [AddonBanner]

class MockCrossSellService: CrossSellClient {
    var events = [Event]()
    var fetchCrossSell: FetchCrossSell
    var fetchAddonBanners: FetchAddonBanners

    enum Event {
        case getCrossSell
        case getAddonBanners
    }

    init(
        fetchCrossSell: @escaping FetchCrossSell,
        fetchAddonBanners: @escaping FetchAddonBanners,

    ) {
        self.fetchCrossSell = fetchCrossSell
        self.fetchAddonBanners = fetchAddonBanners
    }

    func getCrossSell(source: CrossSellSource) async throws -> CrossSells {
        events.append(.getCrossSell)
        let data = try await fetchCrossSell(source)
        return data
    }

    func getAddonBanners(source: AddonSource) async throws -> [AddonBanner] {
        events.append(.getAddonBanners)
        let data = try await fetchAddonBanners(source)
        return data
    }
}
