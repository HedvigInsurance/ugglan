import hCore

public class SelectTierClientOctopus: SelectTierClient {
    public init() {}

    public func getTier() async throws -> TierModel {
        return .init(
            id: "id",
            insuranceDisplayName: "Homeowner",
            streetName: "Bellmansgatan 19A",
            currentPremium: .init(amount: 449, currency: "SEK"),
            newPremium: .init(amount: 599, currency: "SEK"),
            tiers: [.mini, .standard, .max],
            deductibles: [
                .init(id: "Deductible 1", title: "Deductible 1", subTitle: "Subtitle 1", label: "Label 1"),
                .init(id: "Deductible 2", title: "Deductible 2", subTitle: "Subtitle 2", label: "Label 2"),
            ]
        )
    }
}
