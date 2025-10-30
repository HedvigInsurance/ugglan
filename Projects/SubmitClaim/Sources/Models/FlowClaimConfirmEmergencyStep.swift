import Foundation

public struct FlowClaimConfirmEmergencyStepModel: FlowClaimStepModel {
    let text: String
    let options: [FlowClaimConfirmEmergencyOption]

    public init(
        text: String,
        options: [FlowClaimConfirmEmergencyOption]
    ) {
        self.text = text
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
