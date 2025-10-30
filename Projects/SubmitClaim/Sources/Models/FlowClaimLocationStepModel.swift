import Foundation

public struct FlowClaimLocationStepModel: FlowClaimStepModel {
    public internal(set) var location: String?
    let options: [ClaimFlowLocationOptionModel]

    public init(
        location: String? = nil,
        options: [ClaimFlowLocationOptionModel]
    ) {
        self.location = location
        self.options = options
    }

    public func getSelectedOption() -> ClaimFlowLocationOptionModel? {
        options.first(where: { $0.value == location })
    }
}

public struct ClaimFlowLocationOptionModel: Codable, Equatable, Hashable, Sendable {
    let displayName: String
    public let value: String

    public init(displayName: String, value: String) {
        self.displayName = displayName
        self.value = value
    }
}
