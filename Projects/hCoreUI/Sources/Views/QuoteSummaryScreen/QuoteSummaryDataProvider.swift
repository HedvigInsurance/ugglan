import hCore

@MainActor
public protocol QuoteSummaryDataProvider {
    func getTotal(includedAddonIds: [String]) async throws -> Premium
}

public class DirectQuoteSummaryDataProvider: QuoteSummaryDataProvider {
    let intentCost: Premium

    public init(intentCost: Premium) {
        self.intentCost = intentCost
    }
    public func getTotal(includedAddonIds: [String]) async throws -> Premium {
        intentCost
    }
}
