import hCore
import hCoreUI

@MainActor
public protocol ChangeTierQuoteDataProvider {
    func getTotal(
        selectedQuoteId: String,
        includedAddonIds: [String]
    ) async throws -> (premium: Premium, displayItems: [QuoteDisplayItem])
}

public class DirectQuoteSummaryDataProvider: ChangeTierQuoteDataProvider {
    let premium: Premium
    let displayItems: [QuoteDisplayItem]
    public init(premium: Premium, displayItems: [QuoteDisplayItem]) {
        self.premium = premium
        self.displayItems = displayItems
    }
    public func getTotal(
        selectedQuoteId: String,
        includedAddonIds: [String]
    ) async throws -> (premium: Premium, displayItems: [QuoteDisplayItem]) {
        (premium: premium, displayItems: displayItems)
    }
}
