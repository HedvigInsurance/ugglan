import Addons
import CrossSell
import Foundation
import hCore
import hGraphQL

public class CrossSellClientOctopus: CrossSellClient {
    @Inject private var octopus: hOctopus
    public init() {}

    public func getCrossSell() async throws -> [CrossSell] {
        let query = OctopusGraphQL.CrossSellsQuery()
        let crossSells = try await octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)
        return crossSells.currentMember.crossSells.compactMap({
            CrossSell($0.fragments.crossSellFragment)
        })
    }

    public func getCrossSell(source: CrossSellSource) async throws -> CrossSells {
        let query = OctopusGraphQL.CrossSellQuery(
            source: GraphQLEnum<OctopusGraphQL.CrossSellSource>(source.asGraphQLSource)
        )
        let crossSells = try await octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)
        let otherCrossSells: [CrossSell] = crossSells.currentMember.crossSell.otherCrossSells.compactMap({
            CrossSell($0.fragments.crossSellFragment)
        })
        let recommendedCrossSell: CrossSell? = {
            if let crossSellFragment = crossSells.currentMember.crossSell.recommendedCrossSell {
                return CrossSell(crossSellFragment)
            }
            return nil
        }()

        return .init(recommended: recommendedCrossSell, others: otherCrossSells)
    }

    public func getAddonBannerModel(source: AddonSource) async throws -> AddonBannerModel? {
        let query = OctopusGraphQL.UpsellTravelAddonBannerCrossSellQuery(flow: .case(source.getSource))
        let data = try await octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)
        let bannerData = data.currentMember.upsellTravelAddonBanner

        if let bannerData, !bannerData.contractIds.isEmpty {
            return AddonBannerModel(
                contractIds: bannerData.contractIds,
                titleDisplayName: bannerData.titleDisplayName,
                descriptionDisplayName: bannerData.descriptionDisplayName,
                badges: bannerData.badges
            )
        } else {
            throw AddonsError.missingContracts
        }
    }
}

extension CrossSell {
    public init?(_ data: OctopusGraphQL.CrossSellFragment) {
        let type = data.type.crossSellType
        guard type != .unknown else { return nil }
        self.init(
            id: data.id,
            title: data.title,
            description: data.description,
            webActionURL: data.storeUrl,
            type: type,
            buttonDescription: "",
            hasBeenSeen: UserDefaults.standard.bool(
                forKey: Self.hasBeenSeenKey(typeOfContract: type.rawValue)
            )
        )
    }

    public init?(_ data: OctopusGraphQL.CrossSellQuery.Data.CurrentMember.CrossSell.RecommendedCrossSell) {
        let crossSellFragment = data.crossSell.fragments.crossSellFragment
        let type = crossSellFragment.type.crossSellType
        guard type != .unknown else { return nil }
        self.init(
            id: crossSellFragment.id,
            title: crossSellFragment.title,
            description: crossSellFragment.description,
            webActionURL: crossSellFragment.storeUrl,
            type: type,
            bannerText: data.bannerText,
            buttonText: data.buttonText,
            discountText: data.discountText,
            buttonDescription: data.buttonDescription,
            hasBeenSeen: UserDefaults.standard.bool(
                forKey: Self.hasBeenSeenKey(typeOfContract: type.rawValue)
            )
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
            case .apartmentBrf:
                return .apartmentBrf
            case .apartmentRent:
                return .apartmentRent
            case .petCat:
                return .petCat
            case .petDog:
                return .petDog
            case .house:
                return .house
            }
        case .unknown:
            return .unknown
        }
    }
}

extension CrossSellSource {
    fileprivate var asGraphQLSource: OctopusGraphQL.CrossSellSource {
        switch self {
        case .home: return .home
        case .closedClaim: return .closedClaim
        case .changeTier: return .changeTier
        case .addon: return .addon
        case .editCoinsured: return .editCoinsured
        case .movingFlow: return .movingFlow
        }
    }
}
