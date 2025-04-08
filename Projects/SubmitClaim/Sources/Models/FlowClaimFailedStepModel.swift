import Foundation

public struct FlowClaimFailedStepModel: FlowClaimStepModel {
    let id: String

    public init(
        id: String
    ) {
        self.id = id
    }
}
