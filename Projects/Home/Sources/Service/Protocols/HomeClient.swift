import Foundation

@MainActor
public protocol HomeClient {
    func getImportantMessages() async throws -> [ImportantMessage]
    func getMemberState() async throws -> MemberState
    func getQuickActions() async throws -> [QuickAction]
    func getOngoingQuotes() async throws -> [OngoingQuote]
    func getMessagesState() async throws -> MessageState
    func getFAQ() async throws -> HelpCenterFAQModel
    func getHomeData() async throws -> HomeData
}

extension HomeClient {
    /// Composes the single calls, for clients that have no combined request (demo, tests).
    public func getHomeData() async throws -> HomeData {
        try await .init(
            memberState: getMemberState(),
            importantMessages: getImportantMessages(),
            quickActions: getQuickActions()
        )
    }
}

public struct HomeData {
    let memberState: MemberState
    let importantMessages: [ImportantMessage]
    let quickActions: [QuickAction]

    public init(memberState: MemberState, importantMessages: [ImportantMessage], quickActions: [QuickAction]) {
        self.memberState = memberState
        self.importantMessages = importantMessages
        self.quickActions = quickActions
    }
}

public struct MemberState: Sendable {
    let memberInfo: MemberInfo
    let contracts: [HomeContract]
    let contractState: MemberContractState
    let futureState: FutureStatus

    public init(
        memberInfo: MemberInfo,
        contracts: [HomeContract],
        contractState: MemberContractState,
        futureState: FutureStatus
    ) {
        self.memberInfo = memberInfo
        self.contracts = contracts
        self.contractState = contractState
        self.futureState = futureState
    }
}

public struct MessageState: Sendable {
    let hasNewMessages: Bool
    let lastMessageTimeStamp: Date?

    public init(hasNewMessages: Bool, lastMessageTimeStamp: Date?) {
        self.hasNewMessages = hasNewMessages
        self.lastMessageTimeStamp = lastMessageTimeStamp
    }
}
