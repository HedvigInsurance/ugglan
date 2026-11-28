import AuthenticationCore

@MainActor
final class MockPublicImportantMessagesClient: PublicImportantMessagesClient {
    enum Event: Equatable {
        case getMessages
    }

    private var responses: [() async throws -> [PublicImportantMessage]]
    private(set) var events: [Event] = []

    init(responses: [() async throws -> [PublicImportantMessage]]) {
        self.responses = responses
    }

    func getMessages() async throws -> [PublicImportantMessage] {
        events.append(.getMessages)
        guard !responses.isEmpty else { return [] }
        return try await responses.removeFirst()()
    }
}
