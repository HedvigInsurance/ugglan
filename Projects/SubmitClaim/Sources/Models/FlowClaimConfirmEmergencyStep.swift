import Foundation

public struct FlowClaimConfirmEmergencyStepModel: FlowClaimStepModel {
    let id: String
    let text: String
    let confirmEmergency: Bool?
    let options: [FlowClaimConfirmEmergencyOption]

    public init(
        id: String,
        text: String,
        confirmEmergency: Bool?,
        options: [FlowClaimConfirmEmergencyOption]
    ) {
        self.id = id
        self.text = text
        self.confirmEmergency = confirmEmergency
        self.options = options
    }
}

public struct FlowClaimConfirmEmergencyOption: Codable, Equatable, Hashable, Sendable {
    let displayName: String
    let value: Bool

    public init(
        displayName: String,
        value: Bool
    ) {
        self.displayName = displayName
        self.value = value
    }
}
