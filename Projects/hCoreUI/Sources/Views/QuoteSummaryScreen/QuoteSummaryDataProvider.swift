import hCore

@MainActor
public protocol QuoteSummaryDataProvider {
    func getTotal(includedAddonIds: [String]) async throws -> IntentCost
}

public class DirectQuoteSummaryDataProvider: QuoteSummaryDataProvider {
    let intentCost: IntentCost

    public init(intentCost: IntentCost) {
        self.intentCost = intentCost
    }
    public func getTotal(includedAddonIds: [String]) async throws -> IntentCost {
        intentCost
    }
}
