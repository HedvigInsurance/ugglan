import Foundation

public struct FlowClaimInsuranceStepModel: FlowClaimStepModel {
    var selectdeinsuranceId: String
    var availableInsuranceOptions: [FlowClaimInsuranceOptionModel]
}

public struct FlowClaimInsuranceOptionModel: Codable, Equatable, Hashable {
    let displayName: String
    let value: String

    init(
        displayName: String,
        value: String
    ) {
        self.displayName = displayName
        self.value = value
    }
}
