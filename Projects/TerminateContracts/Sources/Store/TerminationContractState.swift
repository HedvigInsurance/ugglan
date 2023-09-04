import Foundation
import Presentation
import hCore

public struct TerminationContractState: StateProtocol {

    public init() {}
    @Transient(defaultValue: false) public var hasLoadedContractBundlesOnce: Bool
    @OptionalTransient var currentTerminationContext: String?
    @OptionalTransient var terminationContractId: String? = ""
    @OptionalTransient var contractName: String?
    @OptionalTransient var terminationDateStep: TerminationFlowDateNextStepModel?
    @OptionalTransient var terminationDeleteStep: TerminationFlowDeletionNextModel?
    @OptionalTransient var successStep: TerminationFlowSuccessNextModel?
    @OptionalTransient var failedStep: TerminationFlowFailedNextModel?
}
