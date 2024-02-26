import Chat

public class HomeDemoService: HomeService {
    public func getImportantMessages() async throws -> [ImportantMessage] {
        return [ImportantMessage(id: "", message: "", link: "")]
    }

    public func getMemberState() async throws -> (
        contracts: [Contract], firstName: String, contractState: MemberContractState, futureState: FutureStatus
    ) {
        let contract = Contract(upcomingRenewal: .init(renewalDate: "", draftCertificateUrl: ""), displayName: "")
        return (
            contracts: [contract], firstName: "", contractState: MemberContractState.active,
            futureState: FutureStatus.none
        )
    }

    public func getCommonClaims() async throws -> [CommonClaim] {
        return [.editCoInsured(), .moving()]
    }

    public func getChatNotifications() async throws -> [Chat.Message] {
        return []
    }

    public func getNumberOfClaims() async throws -> Int {
        return 0
    }

}
