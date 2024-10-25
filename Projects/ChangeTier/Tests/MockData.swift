import Foundation
import hCore

@testable import ChangeTier

struct MockData {
    @discardableResult
    static func createMockChangeTier(
        fetchTier: @escaping GetTier = { _ in
            .init(
                displayName: "display name",
                activationDate: Date(),
                tiers: [],
                currentPremium: .init(amount: "449", currency: "SEK"),
                currentTier: nil,
                currentQuote: nil,
                selectedTier: nil,
                selectedQuote: nil,
                canEditTier: true,
                typeOfContract: .seHouse
            )
        },
        commitTier: @escaping CommitTier = { quoteId in },
        compareProductVariants: @escaping CompareProductVariants = { termsVersion in
            .init(rows: [], variantColumns: [])
        }
    ) -> MockChangeTierService {
        let service = MockChangeTierService(
            fetchTier: fetchTier,
            sendTier: commitTier,
            compareProductVariants: compareProductVariants
        )
        Dependencies.shared.add(module: Module { () -> ChangeTierClient in service })
        return service
    }
}

typealias GetTier = (ChangeTier.ChangeTierInputData) async throws(ChangeTier.ChangeTierError) ->
    ChangeTier.ChangeTierIntentModel
typealias CommitTier = (String) async throws(ChangeTier.ChangeTierError) -> Void
typealias CompareProductVariants = ([String]) async throws -> ProductVariantComparison

class MockChangeTierService: ChangeTierClient {
    var events = [Event]()

    var fetchTier: GetTier
    var sendTier: CommitTier
    var compareProductVariants: CompareProductVariants

    enum Event {
        case getTier
        case commitTier
        case productVariantComparison
    }

    init(
        fetchTier: @escaping GetTier,
        sendTier: @escaping CommitTier,
        compareProductVariants: @escaping CompareProductVariants
    ) {
        self.fetchTier = fetchTier
        self.sendTier = sendTier
        self.compareProductVariants = compareProductVariants
    }

    func getTier(input: ChangeTierInputData) async throws -> ChangeTierIntentModel {
        events.append(.getTier)
        let data = try await fetchTier(input)
        return data
    }

    func commitTier(quoteId: String) async throws {
        try await sendTier(quoteId)
        events.append(.commitTier)
    }

    func compareProductVariants(termsVersion: [String]) async throws -> ProductVariantComparison {
        events.append(.productVariantComparison)
        let data = try await compareProductVariants(termsVersion)
        return data
    }
}
