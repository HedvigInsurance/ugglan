import Apollo
import Flow
import Odyssey
import Presentation
import SwiftUI
import hCore
import hGraphQL

public struct ContractState: StateProtocol {

    public init() {}

    public var hasLoadedContractBundlesOnce = false
    public var contractBundles: LoadingWrapper<[ActiveContractBundle], String> = .loading
    public var contracts: LoadingWrapper<[Contract], String> = .loading
    public var focusedCrossSell: CrossSell?
    public var signedCrossSells: [CrossSell] = []

    var currentTerminationContext: String?
    var terminationContractId: String? = ""
    var terminationDateStep: TerminationFlowDateNextStepModel?
    var terminationDeleteStep: TerminationFlowDeletionNextModel?
    var successStep: TerminationFlowSuccessNextModel?
    var failedStep: TerminationFlowFailedNextModel?
    var loadingStates: [ContractAction: LoadingState<String>] = [:]

    func contractForId(_ id: String) -> Contract? {
        if let inBundleContract = contractBundles.getData()?.flatMap({ $0.contracts })
            .first(where: { contract in
                contract.id == id
            })
        {
            return inBundleContract
        }

        return contracts.getData()?
            .first { contract in
                contract.id == id
            }
    }
}

extension ContractState {
    public var hasUnseenCrossSell: Bool {
        contractBundles.getData()?.contains(where: { bundle in bundle.crossSells.contains(where: { !$0.hasBeenSeen }) })
            ?? false
    }

    public var hasActiveContracts: Bool {
        !(contractBundles.getData()?.flatMap { $0.contracts }.isEmpty ?? false)
    }
}

public enum LoadingState<T>: Codable & Equatable & Hashable where T: Codable & Equatable & Hashable {
    case loading
    case error(error: T)
}
