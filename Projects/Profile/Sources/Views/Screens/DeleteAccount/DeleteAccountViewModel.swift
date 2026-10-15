import Apollo
import Claims
import Combine
import Contracts
import Foundation
import Observation

@MainActor
@Observable
public class DeleteAccountViewModel {
    let claimsStore: ClaimsStore
    let contractsStore: ContractStore

    var hasActiveClaims: Bool = false
    var hasActiveContracts: Bool = false
    @ObservationIgnored private var cancellables = Set<AnyCancellable>()

    public init(
        claimsStore: ClaimsStore,
        contractsStore: ContractStore
    ) {
        self.claimsStore = claimsStore
        self.contractsStore = contractsStore

        hasActiveClaims = self.claimsStore.hasActiveClaims
        hasActiveContracts = self.contractsStore.hasActiveContracts

        claimsStore.$activeClaims
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.hasActiveClaims = claimsStore.hasActiveClaims
            }
            .store(in: &cancellables)

        contractsStore.$activeContracts
            .map { !$0.isEmpty }
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                self?.hasActiveContracts = value
            }
            .store(in: &cancellables)
    }
}
