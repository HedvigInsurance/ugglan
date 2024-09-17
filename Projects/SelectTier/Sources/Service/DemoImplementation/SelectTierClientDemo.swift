import hCore
import hGraphQL

public class SelectTierClientDemo: SelectTierClient {
    @Inject var octopus: hOctopus

    public init() {}

    public func getTier() async throws -> TierModel {
        /* TODO: REPLACE WITH REAL DATA */
        return .init(
            id: "id",
            insuranceDisplayName: "Homeowner",
            streetName: "Bellmansgatan 19A",
            premium: .init(amount: 449, currency: "SEK")
        )
    }
}
