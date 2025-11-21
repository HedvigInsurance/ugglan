import AutomaticLog
import hCore

@MainActor
class ChangeTierService {
    @Inject var client: ChangeTierClient

    @Log
    func getTier(input: ChangeTierInputData) async throws -> ChangeTierIntentModelState {
        try await client.getTier(input: input)
    }

    @Log
    func commitTier(quoteId: String) async throws {
        try await client.commitTier(quoteId: quoteId)
    }

    @Log
    func compareProductVariants(termsVersion: [String]) async throws -> ProductVariantComparison {
        try await client.compareProductVariants(termsVersion: termsVersion)
    }
}
