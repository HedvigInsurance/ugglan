import Addons

public class CrossSellClientDemo: CrossSellClient {
    public init() {}

    public func getCrossSell(source _: CrossSellSource) async throws -> CrossSells {
        let crossSells: [CrossSell] = [
            .init(
                id: "1",
                title: "title",
                description: "description",
                buttonTitle: "See price",
                webActionURL: "",
                imageUrl: nil,
                buttonDescription: "buttonDescription"
            )
        ]
        return .init(recommended: nil, others: crossSells)
    }

    public func getAddonBanners(source: Addons.AddonSource) async throws -> [Addons.AddonBanner] {
        [
            AddonBanner(
                contractIds: [],
                displayTitle: "Travel Plus",
                displayDescription:
                    "Extended travel insurance with extra coverage for your travels",
                badges: ["Popular"],
                addonType: .travelPlus
            )
        ]
    }
}
