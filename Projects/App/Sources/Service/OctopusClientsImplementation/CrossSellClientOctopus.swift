import CrossSell
import Foundation
import hCore
import hGraphQL

@MainActor
public class CrossSellService {
    @Inject var service: CrossSellClient

    public func getCrossSell() async throws -> [CrossSell] {
        log.info("CrossSellService: getCrossSell", error: nil, attributes: nil)
        return try await service.getCrossSell()
    }
}

public class CrossSellClientOctopus: CrossSellClient {
    @Inject private var octopus: hOctopus
    public init() {}

    public func getCrossSell() async throws -> [CrossSell] {
        let query = OctopusGraphQL.CrossSellsQuery()
        let crossSells = try await octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)
        return crossSells.currentMember.fragments.crossSellFragment.crossSells.compactMap({
            CrossSell($0)
        })
    }
}

extension CrossSell {
    public init?(_ data: OctopusGraphQL.CrossSellFragment.CrossSell) {
        let type = data.type.crossSellType
        guard type != .unknown else { return nil }
        self.init(
            title: data.title,
            description: data.description,
            webActionURL: data.storeUrl,
            hasBeenSeen: UserDefaults.standard.bool(
                forKey: Self.hasBeenSeenKey(typeOfContract: type.rawValue)
            ),
            type: type
        )
    }
}

extension GraphQLEnum<OctopusGraphQL.CrossSellType> {
    var crossSellType: CrossSellType {
        switch self {
        case .case(let t):
            switch t {
            case .car:
                return .car
            case .home:
                return .home
            case .accident:
                return .accident
            case .pet:
                return .pet
            }
        case .unknown:
            return .unknown
        }
    }
}
