import Foundation

public protocol HomeService {
    func getImportantMessages() async throws -> [ImportantMessage]
    func getMemberState() async throws -> MemberState
    func getCommonClaims() async throws -> [CommonClaim]
    func getLastMessagesDates() async throws -> [Date]
    func getNumberOfClaims() async throws -> Int
}

public struct MemberState {
    let contracts: [Contract]
    let contractState: MemberContractState
    let futureState: FutureStatus
}
