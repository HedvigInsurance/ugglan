import Foundation

@MainActor
public protocol HomeClient {
    func getImportantMessages() async throws -> [ImportantMessage]
    func getMemberState() async throws -> MemberState
    func getQuickActions() async throws -> [QuickAction]
    func getMessagesState() async throws -> MessageState
}

public struct MemberState: Sendable {
    let contracts: [HomeContract]
    let contractState: MemberContractState
    let futureState: FutureStatus
}

public struct MessageState {
    let hasNewMessages: Bool
    let hasSentOrRecievedAtLeastOneMessage: Bool
    let lastMessageTimeStamp: Date?
}
