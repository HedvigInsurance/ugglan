import Foundation

public struct FlowClaimContractSelectStepModel: FlowClaimStepModel {
    let availableContractOptions: [FlowClaimContractSelectOptionModel]
    var selectedContractId: String?

    public init(
        availableContractOptions: [FlowClaimContractSelectOptionModel],
        selectedContractId: String? = nil
    ) {
        self.availableContractOptions = availableContractOptions
        self.selectedContractId = selectedContractId
    }
}

public struct FlowClaimContractSelectOptionModel: Codable, Equatable, Hashable, Sendable {
    let displayTitle: String
    let displaySubTitle: String?
    let id: String

    public init(displayTitle: String, displaySubTitle: String?, id: String) {
        self.displayTitle = displayTitle
        self.displaySubTitle = displaySubTitle
        self.id = id
    }
}
