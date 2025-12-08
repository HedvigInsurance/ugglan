import Addons
import hCore

@testable import CrossSell

@MainActor
struct MockData {
    static func createMockCrossSellService(
        fetchAddonBannerModel: @escaping FetchAddonBanner = { _ in
            .init(
                contractIds: ["contractId"],
                titleDisplayName: "title",
                descriptionDisplayName: "description",
                badges: []
            )
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

typealias FetchCrossSell = (CrossSellSource) async throws -> CrossSells
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
        fetchAddonBannerModel: @escaping FetchAddonBanner,

    ) {
        self.fetchCrossSell = fetchCrossSell
        self.fetchAddonBannerModel = fetchAddonBannerModel
    }

    func getCrossSell(source: CrossSellSource) async throws -> CrossSells {
        events.append(.getCrossSell)
        let data = try await fetchCrossSell(source)
        return data
    }

    func getAddonBannerModel(source: AddonSource) async throws -> AddonBannerModel? {
        events.append(.getAddonBannerModel)
        let data = try await fetchAddonBannerModel(source)
        return data
    }
}
