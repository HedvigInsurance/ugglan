import Foundation

public class HomeServiceDemo: HomeService {

    public init() {}

    public func getImportantMessages() async throws -> [ImportantMessage] {
        return [ImportantMessage(id: "", message: "", link: "")]
    }

    public func getMemberState() async throws -> MemberState {
        let contract = Contract(upcomingRenewal: .init(renewalDate: "", draftCertificateUrl: ""), displayName: "")
        return .init(
            contracts: [contract],
            contractState: MemberContractState.active,
            futureState: FutureStatus.none
        )
    }

    public func getCommonClaims() async throws -> [CommonClaim] {
        return [.editCoInsured(), .moving()]
    }

    public func getLastMessagesDates() async throws -> [Date] {
        return []
    }

    public func getNumberOfClaims() async throws -> Int {
        return 0
    }

}
