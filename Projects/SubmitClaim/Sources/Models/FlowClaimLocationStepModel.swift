import Foundation

public struct FlowClaimLocationStepModel: FlowClaimStepModel {
    let id: String
    public internal(set) var location: String?
    let options: [ClaimFlowLocationOptionModel]

    public init(
        id: String,
        location: String? = nil,
        options: [ClaimFlowLocationOptionModel]
    ) {
        self.id = id
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
