import Foundation

public struct TerminationFlowSuccessNextModel: FlowStepModel {
    let terminationDate: String?

    public init(
        terminationDate: String?
    ) {
        self.terminationDate = terminationDate
    }
}
