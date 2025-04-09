import Foundation

@MainActor
public protocol HomeClient {
    func getImportantMessages() async throws -> [ImportantMessage]
    func getMemberState() async throws -> MemberState
    func getQuickActions() async throws -> [QuickAction]
    func getMessagesState() async throws -> MessageState
    func getFAQ() async throws -> HelpCenterFAQModel
}

public struct MemberState: Sendable {
    let id: String
    let contracts: [HomeContract]
    let contractState: MemberContractState
    let futureState: FutureStatus

    public init(id: String, contracts: [HomeContract], contractState: MemberContractState, futureState: FutureStatus) {
        self.id = id
        self.contracts = contracts
        self.contractState = contractState
        self.futureState = futureState
    }
}

public struct MessageState: Sendable {
    let hasNewMessages: Bool
    let hasSentOrRecievedAtLeastOneMessage: Bool
    let lastMessageTimeStamp: Date?

    public init(hasNewMessages: Bool, hasSentOrRecievedAtLeastOneMessage: Bool, lastMessageTimeStamp: Date?) {
        self.hasNewMessages = hasNewMessages
        self.hasSentOrRecievedAtLeastOneMessage = hasSentOrRecievedAtLeastOneMessage
        self.lastMessageTimeStamp = lastMessageTimeStamp
    }
}
