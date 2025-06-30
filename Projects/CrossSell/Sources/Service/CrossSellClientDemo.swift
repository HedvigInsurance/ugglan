import Addons

public class CrossSellClientDemo: CrossSellClient {
    public init() {}

    public func getCrossSell() async throws -> [CrossSell] {
        return [
            .init(
                id: "1",
                title: "title",
                description: "description",
                imageUrl: nil,
                buttonDescription: "buttonDescription"
            )
        ]
    }

    public func getCrossSell(source: CrossSellSource) async throws -> CrossSells {
        let crossSells: [CrossSell] = [
            .init(
                id: "1",
                title: "title",
                description: "description",
                imageUrl: nil,
                buttonDescription: "buttonDescription"
            )
        ]
        return .init(recommended: nil, others: crossSells)
    }

    public func getAddonBannerModel(source: AddonSource) async throws -> AddonBannerModel? {
        return nil
    }
}
