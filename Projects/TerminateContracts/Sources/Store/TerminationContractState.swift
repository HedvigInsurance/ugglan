import Foundation
import PresentableStore
import hCore

public struct TerminationContractState: StateProtocol {

    public init() {}
    @OptionalTransient var currentTerminationContext: String?
    @OptionalTransient var terminationDateStep: TerminationFlowDateNextStepModel?
    @OptionalTransient var terminationDeleteStep: TerminationFlowDeletionNextModel?
    @OptionalTransient var successStep: TerminationFlowSuccessNextModel?
    @OptionalTransient var failedStep: TerminationFlowFailedNextModel?
    @OptionalTransient var terminationSurveyStep: TerminationFlowSurveyStepModel?
    @OptionalTransient var config: TerminationConfirmConfig?
    @Transient(defaultValue: false) var hasSelectInsuranceStep: Bool
    @OptionalTransient var progress: Float?
    @OptionalTransient var previousProgress: Float?
    var isDeletion: Bool {
        terminationDeleteStep != nil
    }
}
