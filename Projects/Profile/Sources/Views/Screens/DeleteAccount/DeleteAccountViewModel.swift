import Apollo
import Claims
import Combine
import Contracts
import Flow
import Foundation
import Presentation
import hCore
import hGraphQL

class DeleteAccountViewModel: ObservableObject {
    var memberDetails: MemberDetails
    let claimsStore: ClaimsStore
    let contractsStore: ContractStore
    let bag = DisposeBag()

//    var activeClaimsSignal: ReadSignal<Bool> {
//        self.claimsStore.stateSignal.map { $0.hasActiveClaims }
//    }
//
//    var activeContractsSignal: ReadSignal<Bool> {
//        self.contractsStore.stateSignal.map { $0.hasActiveContracts }
//    }

    @Published var hasActiveClaims: Bool = false
    @Published var hasActiveContracts: Bool = false

    internal init(
        memberDetails: MemberDetails,
        claimsStore: ClaimsStore,
        contractsStore: ContractStore
    ) {
        self.memberDetails = memberDetails
        self.claimsStore = claimsStore
        self.contractsStore = contractsStore

//        self.hasActiveClaims = activeClaimsSignal.value
//        self.hasActiveContracts = activeContractsSignal.value
//
//        bag += activeClaimsSignal.distinct(on: .main).onValue { self.hasActiveClaims = $0 }
//        bag += activeContractsSignal.distinct(on: .main).onValue { self.hasActiveContracts = $0 }
    }

    func deleteAccount() {
//        let store: UgglanStore = globalPresentableStoreContainer.get()
//        store.send(.sendAccountDeleteRequest(details: memberDetails))
    }
}
