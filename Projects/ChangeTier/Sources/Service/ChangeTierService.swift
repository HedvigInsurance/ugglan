import hCore

@MainActor
class ChangeTierService {
    @Inject var client: ChangeTierClient

    func getTier(input: ChangeTierInputData) async throws -> ChangeTierIntentModel {
        log.info("ChangeTierService.getTier: for \(input.asString)", error: nil, attributes: nil)
        return try await client.getTier(input: input)
    }

    func commitTier(quoteId: String) async throws {
        log.info("ChangeTierService.commitTier: with quoteId \(quoteId)", error: nil, attributes: [:])
        try await client.commitTier(quoteId: quoteId)
    }

    func compareProductVariants(termsVersion: [String]) async throws -> ProductVariantComparison {
        let data = try await client.compareProductVariants(termsVersion: termsVersion)
        log.info(
            "ChangeTierService.compareProductVariants: for termsVersion \(termsVersion)",
            error: nil,
            attributes: ["terms": termsVersion]
        )
        return data
    }
}

extension ChangeTierInputData {
    fileprivate func logDescription() -> String {
        ""
    }
}
