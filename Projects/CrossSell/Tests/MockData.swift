import Addons
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
        },
        fetchAddonBannerModel: @escaping FetchAddonBanner = { source in
            .init(
                contractIds: ["contractId"],
                titleDisplayName: "title",
                descriptionDisplayName: "description",
                badges: []
            )
        }
    ) -> MockCrossSellService {
        let service = MockCrossSellService(
            fetchCrossSell: fetchCrossSell,
            fetchAddonBannerModel: fetchAddonBannerModel
        )
        Dependencies.shared.add(module: Module { () -> CrossSellClient in service })
        return service
    }
}

enum MockContractError: Error {
    case fetchCrossSells
    case fetchAddonBanner
}

typealias FetchCrossSell = () async throws -> [CrossSell]
typealias FetchAddonBanner = (AddonSource) async throws -> AddonBannerModel?

class MockCrossSellService: CrossSellClient {
    var events = [Event]()
    var fetchCrossSell: FetchCrossSell
    var fetchAddonBannerModel: FetchAddonBanner

    enum Event {
        case getCrossSell
        case getAddonBannerModel
    }

    init(
        fetchCrossSell: @escaping FetchCrossSell,
        fetchAddonBannerModel: @escaping FetchAddonBanner
    ) {
        self.fetchCrossSell = fetchCrossSell
        self.fetchAddonBannerModel = fetchAddonBannerModel
    }

    func getCrossSell() async throws -> [CrossSell] {
        events.append(.getCrossSell)
        let data = try await fetchCrossSell()
        return data
    }

    func getAddonBannerModel(source: AddonSource) async throws -> AddonBannerModel? {
        events.append(.getAddonBannerModel)
        let data = try await fetchAddonBannerModel(source)
        return data
    }
}
