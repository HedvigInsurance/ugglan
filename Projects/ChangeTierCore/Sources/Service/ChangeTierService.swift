import AutomaticLog
import hCore

@MainActor
public class ChangeTierService {
    @Inject var client: ChangeTierClient

    public init() {}

    @Log
    public func getTier(input: ChangeTierInputData) async throws -> ChangeTierIntentModelState {
        try await client.getTier(input: input)
    }

    @Log
    public func commitTier(quoteId: String) async throws {
        try await client.commitTier(quoteId: quoteId)
    }

    @Log
    public func compareProductVariants(termsVersion: [String]) async throws -> ProductVariantComparison {
        try await client.compareProductVariants(termsVersion: termsVersion)
    }
}
