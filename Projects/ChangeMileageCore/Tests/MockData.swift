import Foundation
import hCore

@testable import ChangeMileageCore

typealias CreateMileageIntent = @MainActor (String) async throws -> ChangeMileageIntent
typealias CommitMileageIntent = @MainActor (String) async throws -> Void

@MainActor
enum MockData {
    @discardableResult
    static func createMockChangeMileage(
        createIntent: @escaping CreateMileageIntent = { _ in MileageFixtures.intent },
        commitIntent: @escaping CommitMileageIntent = { _ in }
    ) -> MockChangeMileageClient {
        let client = MockChangeMileageClient(createIntent: createIntent, commitIntent: commitIntent)
        Dependencies.shared.add(module: Module { () -> ChangeMileageClient in client })
        return client
    }
}

final class MockChangeMileageClient: ChangeMileageClient {
    enum Event: Equatable {
        case createIntent(contractId: String)
        case commitIntent(quoteId: String)
    }

    var events = [Event]()
    private let createIntentClosure: CreateMileageIntent
    private let commitIntentClosure: CommitMileageIntent

    init(createIntent: @escaping CreateMileageIntent, commitIntent: @escaping CommitMileageIntent) {
        createIntentClosure = createIntent
        commitIntentClosure = commitIntent
    }

    func createIntent(contractId: String) async throws -> ChangeMileageIntent {
        events.append(.createIntent(contractId: contractId))
        return try await createIntentClosure(contractId)
    }

    func commitIntent(quoteId: String) async throws {
        events.append(.commitIntent(quoteId: quoteId))
        try await commitIntentClosure(quoteId)
    }
}

enum MileageFixtures {
    static let lowerQuote = MileageQuote(
        id: "lower",
        displayName: "1 000 mil",
        isCurrent: false,
        totalCost: .init(gross: .sek(371), net: .sek(371)),
        displayItems: [.init(title: "Körsträcka per år", value: "1 000 mil", previousValue: "1 500 mil")]
    )

    static let currentQuote = MileageQuote(
        id: "current",
        displayName: "1 500 mil",
        isCurrent: true,
        totalCost: .init(gross: .sek(412), net: .sek(412)),
        displayItems: [.init(title: "Körsträcka per år", value: "1 500 mil", previousValue: nil)]
    )

    static let higherQuote = MileageQuote(
        id: "higher",
        displayName: "2 000 mil",
        isCurrent: false,
        totalCost: .init(gross: .sek(449), net: .sek(449)),
        displayItems: [.init(title: "Körsträcka per år", value: "2 000 mil", previousValue: "1 500 mil")]
    )

    static let intent = ChangeMileageIntent(
        // 2026-11-19
        activationDate: Date(timeIntervalSince1970: 1_795_046_400),
        currentTotalCost: .init(gross: .sek(412), net: .sek(412)),
        quotes: [lowerQuote, currentQuote, higherQuote]
    )

    static let contract = ChangeMileageContract(
        contractId: "contractId",
        displayName: "Bilförsäkring Helförsäkring",
        exposureName: "ABC 123 • Volvo XC40",
        typeOfContract: .seCarFull
    )
}
