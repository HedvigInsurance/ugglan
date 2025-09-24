import hCore
import hCoreUI

@MainActor
public protocol ChangeTierQuoteDataProvider {
    func getTotal(
        selectedQuoteId: String,
        includedAddonIds: [String]
    ) async throws -> (premium: Premium, displayItems: [QuoteDisplayItem])
}
