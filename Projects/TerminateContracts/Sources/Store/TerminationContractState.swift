import Foundation
import Presentation
import hCore

public struct TerminationContractState: StateProtocol {

    public init() {}

    @Transient(defaultValue: false) public var hasLoadedContractBundlesOnce: Bool
    var currentTerminationContext: String?
    var terminationContractId: String? = ""
    var terminationDateStep: TerminationFlowDateNextStepModel?
    var terminationDeleteStep: TerminationFlowDeletionNextModel?
    var successStep: TerminationFlowSuccessNextModel?
    var failedStep: TerminationFlowFailedNextModel?
}
