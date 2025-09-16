import hCore
import hCoreUI

class MoveFlowQuoteSummaryDataProvider: QuoteSummaryDataProvider {
    let intentId: String
    let selectedHomeQuoteId: String
    @Inject private var client: MoveFlowClient

    init(intentId: String, selectedHomeQuoteId: String) {
        self.intentId = intentId
        self.selectedHomeQuoteId = selectedHomeQuoteId
    }

    func getTotal(includedAddonIds: [String]) async throws -> Premium {
        try await client.getMoveIntentCost(
            input: .init(
                intentId: intentId,
                selectedHomeQuoteId: selectedHomeQuoteId,
                selectedAddons: includedAddonIds
            )
        )
    }
}
