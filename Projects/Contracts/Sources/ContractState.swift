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
    public var contractBundles: [ActiveContractBundle] = []
    public var contracts: [Contract] = []
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
        if let inBundleContract = contractBundles.flatMap({ $0.contracts })
            .first(where: { contract in
                contract.id == id
            })
        {
            return inBundleContract
        }

        return contracts.first { contract in
            contract.id == id
        }
    }
}

extension ContractState {
    public var hasUnseenCrossSell: Bool {
        contractBundles.contains(where: { bundle in bundle.crossSells.contains(where: { !$0.hasBeenSeen }) })
    }

    public var hasActiveContracts: Bool {
        !contractBundles.flatMap { $0.contracts }.isEmpty
    }
}

public enum LoadingState<T>: Codable & Equatable where T: Codable & Equatable {
    case loading
    case error(error: T)
}
