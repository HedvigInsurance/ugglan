public class AddonsClientOctopus: AddonsClient {
    public init() {}

    public func getAddons() async throws -> [AddonModel] {
        let addons: [AddonModel] = [
            .init(title: "Reseskydd", subTitle: nil, tag: "Ingår", coverageDays: nil),
            .init(
                title: "Reseskydd Plus",
                subTitle: "För dig som reser mycket, bagageskydd, hjälp överallt i världen 24/7.",
                tag: "+ 49 kr/mo",
                coverageDays: [45, 60]
            ),
        ]

        return addons
    }
}
