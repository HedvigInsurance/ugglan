import Foundation

public struct FlowClaimSuccessStepModel: FlowClaimStepModel {
    let id: String

    public init(
        id: String
    ) {
        self.id = id
    }
}
