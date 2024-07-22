import Apollo
import Claims
import Combine
import Contracts
import Foundation
import Presentation
import hCore
import hGraphQL

public class DeleteAccountViewModel: ObservableObject {
    var memberDetails: MemberDetails
    let claimsStore: ClaimsStore
    let contractsStore: ContractStore

    private var activeClaimsSignal: AnyPublisher<Bool, Never> {
        self.claimsStore.stateSignal.plain().map({ $0.hasActiveClaims }).publisher.eraseToAnyPublisher()
    }

    private var activeContractsSignal: AnyPublisher<Bool, Never> {
        self.contractsStore.stateSignal.plain().map({ $0.hasActiveContracts }).publisher.eraseToAnyPublisher()
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

        self.hasActiveClaims = self.claimsStore.stateSignal.map({ $0.hasActiveClaims }).value
        self.hasActiveContracts = self.contractsStore.stateSignal.map({ $0.hasActiveContracts }).value

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
