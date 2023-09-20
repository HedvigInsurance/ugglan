import Foundation
import hGraphQL

public struct FlowClaimConfirmEmergencyStepModel: FlowClaimStepModel {
    let id: String
    let text: String
    let confirmEmergency: Bool?
    let options: [FlowClaimConfirmEmergencyOption]
    
    init(
        with data: OctopusGraphQL.FlowClaimConfirmEmergencyStepFragment
    ) {
        self.id = data.id
        self.text = data.text
        self.confirmEmergency = data.confirmEmergency
        self.options = data.options.map({ data in FlowClaimConfirmEmergencyOption(displayName: data.displayName, value: data.displayValue) })
    }
}

public struct FlowClaimConfirmEmergencyOption: Codable, Equatable, Hashable {
    let displayName: String
    let value: Bool
    
    init(
        displayName: String,
        value: Bool
    ) {
        self.displayName = displayName
        self.value = value
    }
}
