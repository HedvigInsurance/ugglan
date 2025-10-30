import Apollo
import Claims
import Combine
import Contracts
import Foundation

@MainActor
public class DeleteAccountViewModel: ObservableObject {
    let claimsStore: ClaimsStore
    let contractsStore: ContractStore

    private var activeClaimsSignal: AnyPublisher<Bool, Never> {
        claimsStore.stateSignal.map(\.hasActiveClaims).eraseToAnyPublisher()
    }

    private var activeContractsSignal: AnyPublisher<Bool, Never> {
        contractsStore.stateSignal.map(\.hasActiveContracts).eraseToAnyPublisher()
    }

    @Published var hasActiveClaims: Bool = false
    @Published var hasActiveContracts: Bool = false
    private var cancellables = Set<AnyCancellable>()

    public init(
        claimsStore: ClaimsStore,
        contractsStore: ContractStore
    ) {
        self.claimsStore = claimsStore
        self.contractsStore = contractsStore

        hasActiveClaims = self.claimsStore.state.hasActiveClaims
        hasActiveContracts = self.contractsStore.state.hasActiveContracts

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
