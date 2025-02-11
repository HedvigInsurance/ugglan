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
    let contracts: [HomeContract]
    let contractState: MemberContractState
    let futureState: FutureStatus
}

public struct MessageState: Sendable {
    let hasNewMessages: Bool
    let hasSentOrRecievedAtLeastOneMessage: Bool
    let lastMessageTimeStamp: Date?
}
