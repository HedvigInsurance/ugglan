import Addons

public class CrossSellClientDemo: CrossSellClient {
    public init() {}

    public func getCrossSell() async throws -> [CrossSell] {
        return [.init(title: "title", description: "description", type: .home)]
    }

    public func getCrossSell(source: CrossSellSource) async throws -> CrossSells {
        let crossSells: [CrossSell] = [
            .init(title: "title", description: "description", type: .home)
        ]
        return .init(recommended: nil, others: crossSells)
    }

    public func getAddonBannerModel(source: AddonSource) async throws -> AddonBannerModel? {
        return nil
    }
}
