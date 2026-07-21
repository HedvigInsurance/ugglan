import Addons
import CrossSell
import Foundation
import hCore
import hGraphQL

class CrossSellClientOctopus: CrossSellClient {
    @Inject private var octopus: hOctopus
    @Inject private var addonClient: AddonsClient

    func getCrossSell(source: CrossSellSource, contractId: String?) async throws -> CrossSells {
        let flowSource: GraphQLNullable<GraphQLEnum<OctopusGraphQL.FlowSource>> = {
            if let flowSource = source.asGraphQLFlowSource {
                return .some(GraphQLEnum<OctopusGraphQL.FlowSource>(flowSource))
            }
            return
                .null
        }()
        let contractIdInput: GraphQLNullable<OctopusGraphQL.ID> = {
            if let contractId {
                return .some(contractId)
            }
            return .null
        }()
        let crossSellsInput = OctopusGraphQL.CrossSellInput(
            userFlow: GraphQLEnum<OctopusGraphQL.UserFlow>.case(source.asGraphQLUserFlow),
            flowSource: flowSource,
            experiments: [],
            contractId: contractIdInput
        )

        let query = OctopusGraphQL.CrossSellQuery(input: crossSellsInput)
        let crossSells = try await octopus.client.fetch(query: query)
        let otherCrossSells: [CrossSell] = crossSells.currentMember.crossSellV2.otherCrossSells.compactMap {
            CrossSell($0.fragments.crossSellFragment)
        }
        let recommendedCrossSell: RecommendedCrossSell? = {
            // Addon recommendations take priority: the backend returns at most one of them and only
            // for the contract in `input.contractId`, so a present addon is the single recommendation.
            if let addon = crossSells.currentMember.crossSellV2.recommendedAddon {
                return .addon(AddonCrossSell(addon))
            }
            if let crossSellFragment = crossSells.currentMember.crossSellV2.recommendedCrossSell,
                let crossSell = CrossSell(crossSellFragment)
            {
                return .insurance(crossSell)
            }
            return nil
        }()
        let discountAvailable = crossSells.currentMember.crossSellV2.discountAvailable
        return .init(recommended: recommendedCrossSell, others: otherCrossSells, discountAvailable: discountAvailable)
    }

    func getAddonBanners(source: AddonSource) async throws -> [AddonBanner] {
        try await addonClient.getAddonBanners(source: source)
    }
}

extension CrossSell {
    public init?(_ data: OctopusGraphQL.CrossSellFragment) {
        self.init(
            id: data.id,
            title: data.title,
            description: data.description,
            buttonTitle: data.buttonTitle,
            webActionURL: data.storeUrl,
            imageUrl: URL(string: data.pillowImageSmall.src),
            buttonDescription: ""
        )
    }

    public init?(_ data: OctopusGraphQL.CrossSellQuery.Data.CurrentMember.CrossSellV2.RecommendedCrossSell) {
        let crossSellFragment = data.crossSell.fragments.crossSellFragment
        self.init(
            id: crossSellFragment.id,
            title: crossSellFragment.title,
            description: crossSellFragment.description,
            buttonTitle: crossSellFragment.buttonTitle,
            webActionURL: crossSellFragment.storeUrl,
            bannerText: data.bannerText,
            buttonText: data.buttonText,
            discountText: data.discountText,
            imageUrl: URL(string: crossSellFragment.pillowImageLarge.src),
            buttonDescription: data.buttonDescription,
            discountPercent: data.discountPercent,
            leftImage: URL(string: data.backgroundPillowImages?.leftImage.src),
            rightImage: URL(string: data.backgroundPillowImages?.rightImage.src),
            numberOfEligibleContracts: data.numberOfEligibleContracts
        )
    }
}

extension AddonCrossSell {
    init(_ data: OctopusGraphQL.CrossSellQuery.Data.CurrentMember.CrossSellV2.RecommendedAddon) {
        self.init(
            id: data.id,
            title: data.title,
            description: data.description,
            buttonText: data.buttonText,
            deepLink: data.deepLink,
            bannerText: data.bannerText,
            benefits: data.benefits,
            imageUrl: URL(string: data.pillowImageLarge.src)
        )
    }
}

extension CrossSellSource {
    fileprivate var asGraphQLUserFlow: OctopusGraphQL.UserFlow {
        switch self {
        case .home: return .homeXSell
        case .closedClaim: return .smartXSell
        case .changeTier: return .smartXSell
        case .addon: return .smartXSell
        case .movingFlow: return .smartXSell
        case .insurances: return .insurances
        }
    }

    fileprivate var asGraphQLFlowSource: OctopusGraphQL.FlowSource? {
        switch self {
        case .home: return nil
        case .closedClaim: return .closedClaim
        case .changeTier: return .changeTier
        case .addon: return .addon
        case .movingFlow: return .moving
        case .insurances: return nil
        }
    }
}
