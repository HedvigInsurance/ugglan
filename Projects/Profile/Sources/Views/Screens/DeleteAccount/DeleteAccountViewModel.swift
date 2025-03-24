import Apollo
import Claims
import Combine
import Contracts
import Foundation
import hCore

@MainActor
public class DeleteAccountViewModel: ObservableObject {
    var memberDetails: MemberDetails
    let claimsStore: ClaimsStore
    let contractsStore: ContractStore

    private var activeClaimsSignal: AnyPublisher<Bool, Never> {
        self.claimsStore.stateSignal.map({ $0.hasActiveClaims }).eraseToAnyPublisher()
    }

    private var activeContractsSignal: AnyPublisher<Bool, Never> {
        self.contractsStore.stateSignal.map({ $0.hasActiveContracts }).eraseToAnyPublisher()
    }

    @Published var hasActiveClaims: Bool = false
    @Published var hasActiveContracts: Bool = false
    private var cancellables = Set<AnyCancellable>()

    public init(
        memberDetails: MemberDetails,
        claimsStore: ClaimsStore,
        contractsStore: ContractStore
    ) {
        self.memberDetails = memberDetails
        self.claimsStore = claimsStore
        self.contractsStore = contractsStore

        self.hasActiveClaims = self.claimsStore.state.hasActiveClaims
        self.hasActiveContracts = self.contractsStore.state.hasActiveContracts

        activeClaimsSignal
            .receive(on: RunLoop.main)
            .sink { value in
                self.hasActiveClaims = value
            }
            .store(in: &cancellables)

        activeContractsSignal
            .receive(on: RunLoop.main)
            .sink { value in
                self.hasActiveContracts = value
            }
            .store(in: &cancellables)
    }
}
