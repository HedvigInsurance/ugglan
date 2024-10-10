import Foundation

public class HomeClientDemo: HomeClient {

    public init() {}

    public func getImportantMessages() async throws -> [ImportantMessage] {
        return []
    }

    public func getMemberState() async throws -> MemberState {
        return .init(
            contracts: [],
            contractState: MemberContractState.active,
            futureState: FutureStatus.none
        )
    }

    public func getQuickActions() async throws -> [QuickAction] {
        return [.editCoInsured, .changeAddress]
    }

    public func getMessagesState() async throws -> MessageState {
        return .init(hasNewMessages: false, hasSentOrRecievedAtLeastOneMessage: true, lastMessageTimeStamp: nil)
    }

    public func getNumberOfClaims() async throws -> Int {
        return 0
    }

}
