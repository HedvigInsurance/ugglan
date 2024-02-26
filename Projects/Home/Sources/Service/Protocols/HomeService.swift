import Chat

public protocol HomeService {
    func getImportantMessages() async throws -> [ImportantMessage]
    func getMemberState() async throws -> (
        contracts: [Contract], firstName: String, contractState: MemberContractState, futureState: FutureStatus
    )
    func getCommonClaims() async throws -> [CommonClaim]
    func getChatNotifications() async throws -> [Message]
    func getNumberOfClaims() async throws -> Int
}
