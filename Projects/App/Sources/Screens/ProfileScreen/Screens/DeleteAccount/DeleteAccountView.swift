import Foundation
import Flow
import SwiftUI
import hCore
import Combine
import Claims
import Contracts

struct DeleteAccountView: View {
    @ObservedObject var viewModel: DeleteAccountViewModel
    
    var body: some View {
        if viewModel.hasActiveClaims {
            // Show error state for having claims
            Text("has active claims")
        } else if viewModel.hasActiveContracts {
            // Show error state for having active contracts
            Text("has active contracts")
        } else {
            // Show the screen for deleting claims
            Text("Placeholder text")
        }
    }
}

class DeleteAccountViewModel: ObservableObject {
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
        
        bag += activeClaimsSignal.onValue {
            self.hasActiveClaims = $0
        }
        bag += activeContractsSignal.plain().onValue { self.hasActiveContracts = $0 }
    }
}
