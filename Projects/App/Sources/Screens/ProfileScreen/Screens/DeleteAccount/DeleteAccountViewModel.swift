import Foundation
import hCore
import Combine
import Claims
import Contracts
import hGraphQL
import Flow
import Apollo

class DeleteAccountViewModel: ObservableObject {
    @Inject var client: ApolloClient
    
    var memberDetails: MemberDetails?
    let claimsStore: ClaimsStore
    let contractsStore: ContractStore
    let bag = DisposeBag()
    
    var activeClaimsSignal: ReadSignal<Bool> {
        self.claimsStore.stateSignal.map { $0.hasActiveClaims }
    }
    
    var activeContractsSignal: ReadSignal<Bool> {
        self.contractsStore.stateSignal.map { $0.hasActiveContracts }
    }
    
    @Published var hasActiveClaims: Bool = false
    @Published var hasActiveContracts: Bool = false
    
    internal init(
        claimsStore: ClaimsStore,
        contractsStore: ContractStore
    ) {
        self.claimsStore = claimsStore
        self.contractsStore = contractsStore
        
        self.hasActiveClaims = activeClaimsSignal.value
        self.hasActiveContracts = activeContractsSignal.value
        
        bag += activeClaimsSignal.onValue { self.hasActiveClaims = $0 }
        bag += activeContractsSignal.onValue { self.hasActiveContracts = $0 }
    }
    
    func deleteMemberRequest() {
        guard let memberDetails = memberDetails else {
            self.fetchMemberDetails { [weak self] details in
                self?.sendSlackMessage(details)
            }
            return
        }

        sendSlackMessage(memberDetails)
    }
    
    private func sendSlackMessage(_ memberDetails: MemberDetails) {
        let bot = SlackBot()
        bot.postSlackMessage(memberDetails: memberDetails) { result in
            switch result {
            case let .success(value):
                value ? print("Message delivered successfully") : print("Message not delivered")
            case let .failure(error):
                // TODO: Handle error
                print(error)
            }
        }
    }
    
    func fetchMemberDetails(_ completion: ((MemberDetails) -> Void)? = nil) {
        bag += client.fetch(
            query: GraphQL.MemberDetailsQuery(),
            cachePolicy: .returnCacheDataElseFetch,
            queue: .global(qos: .background)
        )
            .valueSignal
            .compactMap(on: .background) { MemberDetails(memberData: $0.member) }
            .compactMap(on: .main) { details in
                self.memberDetails = details
                completion?(details)
            }
    }
}
