import AutomaticLog
import hCore

@MainActor
public class ChangeMileageService {
    @Inject var client: ChangeMileageClient

    public init() {}

    @Log
    public func createIntent(contractId: String) async throws -> ChangeMileageIntent {
        try await client.createIntent(contractId: contractId)
    }

    @Log
    public func commitIntent(quoteId: String) async throws {
        try await client.commitIntent(quoteId: quoteId)
    }
}
