import LogMacro
import hCore

@MainActor
class ChangeTierService {
    @Inject var client: ChangeTierClient

    @Log
    func getTier(input: ChangeTierInputData) async throws -> ChangeTierIntentModel {
        try await client.getTier(input: input)
    }

    @Log
    func commitTier(quoteId: String) async throws {
        try await client.commitTier(quoteId: quoteId)
    }

    @Log
    func compareProductVariants(termsVersion: [String]) async throws -> ProductVariantComparison {
        let data = try await client.compareProductVariants(termsVersion: termsVersion)
        return data
    }
}
