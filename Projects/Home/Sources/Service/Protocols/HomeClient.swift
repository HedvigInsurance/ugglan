import Foundation

public protocol HomeClient {
    func getImportantMessages() async throws -> [ImportantMessage]
    func getMemberState() async throws -> MemberState
    func getQuickActions() async throws -> [QuickAction]
    func getLastMessagesDates() async throws -> [Date]
    func getNumberOfClaims() async throws -> Int
}

public struct MemberState {
    let contracts: [HomeContract]
    let contractState: MemberContractState
    let futureState: FutureStatus
}
