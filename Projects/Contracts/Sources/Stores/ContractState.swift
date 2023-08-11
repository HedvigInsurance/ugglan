import Apollo
import Flow
import Presentation
import SwiftUI
import hAnalytics
import hCore
import hGraphQL

public struct ContractState: StateProtocol {

    public init() {}

    @Transient(defaultValue: false) public var hasLoadedContractBundlesOnce: Bool
    public var contractBundles: [ActiveContractBundle] = []
    public var contracts: [Contract] = []
    public var focusedCrossSell: CrossSell?
    public var signedCrossSells: [CrossSell] = []
    public var crossSells: [CrossSell] = []

    var currentTerminationContext: String?
    var terminationContractId: String? = ""
    var terminationDateStep: TerminationFlowDateNextStepModel?
    var terminationDeleteStep: TerminationFlowDeletionNextModel?
    var successStep: TerminationFlowSuccessNextModel?
    var failedStep: TerminationFlowFailedNextModel?

    var movingFlowModel: MovingFlowModel?

    func contractForId(_ id: String) -> Contract? {
        if let inBundleContract = contractBundles.flatMap({ $0.contracts })
            .first(where: { contract in
                contract.id == id
            })
        {
            return inBundleContract
        }

        return
            contracts
            .first { contract in
                contract.id == id
            }
    }
}

extension ContractState {
    public var hasUnseenCrossSell: Bool {
        crossSells.contains(where: { crossSell in !crossSell.hasBeenSeen })
    }

    public var hasActiveContracts: Bool {
        !(contractBundles.flatMap { $0.contracts }.isEmpty)
    }

    public var isTravelInsuranceIncluded: Bool {
        return contractBundles.flatMap({ $0.contracts }).contains(where: { $0.hasTravelInsurance })
            && hAnalyticsExperiment.travelInsurance
    }
}
