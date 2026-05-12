import Foundation
import hCore

@testable import Home

@MainActor
struct MockData {
    @discardableResult
    static func createMockHomeService(
        fetchImportantMessages: @escaping FetchImportantMessages = {
            []
        },
        fetchMemberState: @escaping FetchMemberState = {
            .init(
                memberInfo: .init(id: "id", isContactInfoUpdateNeeded: false),
                contracts: [],
                contractState: .active,
                futureState: .none
            )
        },
        fetchMissedCharge: @escaping FetchMissedCharge = {
            false
        },
        fetchQuickActions: @escaping FetchQuickActions = {
            [
                .editCoInsured,
                .connectPayments,
            ]
        },
        fetchLatestMessageState: @escaping FetchLatestMessageState = {
            .init(hasNewMessages: false, hasSentOrRecievedAtLeastOneMessage: false, lastMessageTimeStamp: nil)
        },
        fetchFAQ: @escaping FetchFAQ = {
            .init(topics: [], commonQuestions: [])
        }
    ) -> MockHomeService {
        let service = MockHomeService(
            fetchImportantMessages: fetchImportantMessages,
            fetchMemberState: fetchMemberState,
            fetchMissedCharge: fetchMissedCharge,
            fetchQuickActions: fetchQuickActions,
            fetchLatestMessageState: fetchLatestMessageState,
            fetchFAQ: fetchFAQ
        )
        Dependencies.shared.add(module: Module { () -> HomeClient in service })
        return service
    }
}

typealias FetchImportantMessages = () async throws -> [ImportantMessage]
typealias FetchMemberState = () async throws -> MemberState
typealias FetchMissedCharge = () async throws -> Bool
typealias FetchQuickActions = () async throws -> [QuickAction]
typealias FetchLatestMessageState = @Sendable () async throws -> Home.MessageState
typealias FetchFAQ = () async throws -> Home.HelpCenterFAQModel

class MockHomeService: HomeClient {
    var events = [Event]()
    var fetchImportantMessages: FetchImportantMessages
    var fetchMemberState: FetchMemberState
    var fetchMissedCharge: FetchMissedCharge
    var fetchQuickActions: FetchQuickActions
    var fetchLatestMessageState: FetchLatestMessageState
    var fetchFAQ: FetchFAQ
    enum Event {
        case getImportantMessages
        case getMemberState
        case getMissedCharge
        case getQuickActions
        case getMessagesState
        case getFaq
    }

    init(
        fetchImportantMessages: @escaping FetchImportantMessages,
        fetchMemberState: @escaping FetchMemberState,
        fetchMissedCharge: @escaping FetchMissedCharge,
        fetchQuickActions: @escaping FetchQuickActions,
        fetchLatestMessageState: @escaping FetchLatestMessageState,
        fetchFAQ: @escaping FetchFAQ
    ) {
        self.fetchImportantMessages = fetchImportantMessages
        self.fetchMemberState = fetchMemberState
        self.fetchMissedCharge = fetchMissedCharge
        self.fetchQuickActions = fetchQuickActions
        self.fetchLatestMessageState = fetchLatestMessageState
        self.fetchFAQ = fetchFAQ
    }

    func getImportantMessages() async throws -> [ImportantMessage] {
        events.append(.getImportantMessages)
        let data = try await fetchImportantMessages()
        return data
    }

    func getMemberState() async throws -> MemberState {
        events.append(.getMemberState)
        let data = try await fetchMemberState()
        return data
    }

    func getMissedCharge() async throws -> Bool {
        events.append(.getMissedCharge)
        let data = try await fetchMissedCharge()
        return data
    }

    func getQuickActions() async throws -> [QuickAction] {
        events.append(.getQuickActions)
        let data = try await fetchQuickActions()
        return data
    }

    func getMessagesState() async throws -> Home.MessageState {
        events.append(.getMessagesState)
        let data = try await fetchLatestMessageState()
        return data
    }

    func getFAQ() async throws -> Home.HelpCenterFAQModel {
        events.append(.getFaq)
        let data = try await fetchFAQ()
        return data
    }
}
