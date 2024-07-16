import Foundation

public protocol HomeClient {
    func getImportantMessages() async throws -> [ImportantMessage]
    func getMemberState() async throws -> MemberState
    func getQuickActions() async throws -> [QuickAction]
    func getLastMessagesDates() async throws -> [String: Date]
}

public struct MemberState {
    let contracts: [HomeContract]
    let contractState: MemberContractState
    let futureState: FutureStatus
}
