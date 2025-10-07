import Foundation
import hCore

@testable import ChangeTier

@MainActor
struct MockData {
    @discardableResult
    static func createMockChangeTier(
        fetchTier: @escaping GetTier = { _ in
            .init(
                displayName: "display name",
                activationDate: Date(),
                tiers: [],
                currentTier: nil,
                currentQuote: nil,
                selectedTier: nil,
                selectedQuote: nil,
                canEditTier: true,
                typeOfContract: .seHouse,
                relatedAddons: [:]
            )
        },
        commitTier: @escaping CommitTier = { _ in },
        compareProductVariants: @escaping CompareProductVariants = { _ in
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

typealias GetTier = @MainActor (ChangeTier.ChangeTierInputData) async throws(ChangeTier.ChangeTierError) ->
    ChangeTier.ChangeTierIntentModel
typealias CommitTier = @MainActor (String) async throws(ChangeTier.ChangeTierError) -> Void
typealias CompareProductVariants = @MainActor ([String]) async throws -> ProductVariantComparison

class MockChangeTierService: ChangeTierClient {
    var events = [Event]()

    var fetchTier: GetTier
    var sendTier: CommitTier
    var compareProductVariantsClosure: CompareProductVariants

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
        compareProductVariantsClosure = compareProductVariants
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
        let data = try await compareProductVariantsClosure(termsVersion)
        return data
    }
}
