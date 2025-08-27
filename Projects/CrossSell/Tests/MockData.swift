import Addons
import hCore

@testable import CrossSell

@MainActor
struct MockData {
    static func createMockCrossSellService(
        fetchCrossSell: @escaping FetchCrossSell = {
            [
                .init(
                    id: "crossSellId",
                    title: "title",
                    description: "description",
                    imageUrl: nil,
                    buttonDescription: "button description"
                )
            ]
        },
        fetchAddonBannerModel: @escaping FetchAddonBanner = { _ in
            .init(
                contractIds: ["contractId"],
                titleDisplayName: "title",
                descriptionDisplayName: "description",
                badges: []
            )
        },
        fetchCrossSells: @escaping FetchCrossSells = { _ in
            .init(recommended: nil, others: [])
        }
    ) -> MockCrossSellService {
        let service = MockCrossSellService(
            fetchCrossSell: fetchCrossSell,
            fetchAddonBannerModel: fetchAddonBannerModel,
            fetchCrossSells: fetchCrossSells
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
typealias FetchCrossSells = (CrossSellSource) async throws -> CrossSells

class MockCrossSellService: CrossSellClient {
    var events = [Event]()
    var fetchCrossSell: FetchCrossSell
    var fetchAddonBannerModel: FetchAddonBanner
    var fetchCrossSells: FetchCrossSells

    enum Event {
        case getCrossSell
        case getAddonBannerModel
        case getCrossSells
    }

    init(
        fetchCrossSell: @escaping FetchCrossSell,
        fetchAddonBannerModel: @escaping FetchAddonBanner,
        fetchCrossSells: @escaping FetchCrossSells

    ) {
        self.fetchCrossSell = fetchCrossSell
        self.fetchAddonBannerModel = fetchAddonBannerModel
        self.fetchCrossSells = fetchCrossSells
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

    func getCrossSell(source: CrossSellSource) async throws -> CrossSells {
        events.append(.getCrossSells)
        let data = try await fetchCrossSells(source)
        return data
    }
}
