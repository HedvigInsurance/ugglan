import Addons

public class CrossSellClientDemo: CrossSellClient {
    public init() {}

    public func getCrossSell(source: CrossSellSource) async throws -> CrossSells {
        // The in-chat prompt only renders when there is a recommendation, so demo mode
        // needs one here. Other flows keep their existing recommendation-free shape.
        if source == .inChat {
            return .init(
                recommended: .insurance(
                    .init(
                        id: "in-chat-demo",
                        title: "Bundle discount",
                        description: "Activate your discount by taking out one more insurance.",
                        buttonTitle: "See your price",
                        webActionURL: "",
                        bannerText: "Get a 15% bundle discount",
                        buttonText: "See your price",
                        imageUrl: nil,
                        buttonDescription:
                            "Activate your discount by taking out one more insurance for home, pet or car.",
                        discountPercent: 15
                    )
                ),
                others: []
            )
        }
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
