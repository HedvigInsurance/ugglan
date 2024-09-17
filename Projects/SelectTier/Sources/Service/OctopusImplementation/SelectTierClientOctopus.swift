import hCore

public class SelectTierClientOctopus: SelectTierClient {
    public init() {}

    public func getTier() async throws -> TierModel {
        return .init(
            id: "id",
            insuranceDisplayName: "Homeowner",
            streetName: "Bellmansgatan 19A",
            premium: .init(amount: 449, currency: "SEK")
        )
    }
}
