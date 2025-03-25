import Addons
import hCore
import hGraphQL

@MainActor
public class CrossSellService {
    @Inject var service: CrossSellClient

    public func getCrossSell() async throws -> [CrossSell] {
        log.info("CrossSellService: getCrossSell", error: nil, attributes: nil)
        return try await service.getCrossSell()
    }

    public func getAddonBannerModel(source: AddonSource) async throws -> AddonBannerModel? {
        log.info("CrossSellService: getAddonBannerModel", error: nil, attributes: nil)
        return try await service.getAddonBannerModel(source: source)
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
