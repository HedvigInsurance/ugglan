import Addons

public class CrossSellClientDemo: CrossSellClient {
    public init() {}

    public func getCrossSell() async throws -> [CrossSell] {
        [
            .init(
                id: "1",
                title: "title",
                description: "description",
                buttonTitle: "Save 15%",
                imageUrl: nil,
                buttonDescription: "buttonDescription"
            )
        ]
    }

    public func getCrossSell(source _: CrossSellSource) async throws -> CrossSells {
        let crossSells: [CrossSell] = [
            .init(
                id: "1",
                title: "title",
                description: "description",
                buttonTitle: "Save 15%",
                imageUrl: nil,
                buttonDescription: "buttonDescription"
            )
        ]
        return .init(recommended: nil, others: crossSells)
    }

    public func getAddonBannerModel(source _: AddonSource) async throws -> AddonBannerModel? {
        nil
    }
}
