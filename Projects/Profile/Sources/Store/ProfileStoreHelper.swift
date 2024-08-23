import Contracts
import Foundation
import Presentation

extension ProfileState {
    func getContractStore() -> ContractStore {
        return globalPresentableStoreContainer.get()
    }
}
