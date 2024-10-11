import Foundation
import hCore

@testable import ChangeTier

struct MockData {
    @discardableResult
    static func createMockChangeTier(
        fetchTier: @escaping GetTier = { _ in
            .init(
                activationDate: Date(),
                tiers: [],
                currentPremium: .init(amount: "449", currency: "SEK"),
                currentTier: nil,
                currentDeductible: nil,
                selectedTier: nil,
                selectedDeductible: nil,
                canEditTier: true,
                typeOfContract: .seHouse
            )
        },
        commitTier: @escaping CommitTier = { quoteId in }
    ) -> MockChangeTierService {
        let service = MockChangeTierService(
            fetchTier: fetchTier,
            sendTier: commitTier
        )
        Dependencies.shared.add(module: Module { () -> ChangeTierClient in service })
        return service
    }
}

typealias GetTier = (ChangeTier.ChangeTierInputData) async throws(ChangeTier.ChangeTierError) ->
    ChangeTier.ChangeTierIntentModel
typealias CommitTier = (String) async throws(ChangeTier.ChangeTierError) -> Void

class MockChangeTierService: ChangeTierClient {
    var events = [Event]()

    var fetchTier: GetTier
    var sendTier: CommitTier

    enum Event {
        case getTier
        case commitTier
    }

    init(
        fetchTier: @escaping GetTier,
        sendTier: @escaping CommitTier
    ) {
        self.fetchTier = fetchTier
        self.sendTier = sendTier
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
}
