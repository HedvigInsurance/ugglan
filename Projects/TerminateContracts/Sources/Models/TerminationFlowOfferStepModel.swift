public struct TerminationFlowOfferStepModel: FlowStepModel {
    let title: String
    let description: String
    let buttonTitle: String
    let skipButtonTitle: String
    let action: TerminationOfferAction

    public init(
        title: String,
        description: String,
        buttonTitle: String,
        skipButtonTitle: String,
        action: TerminationOfferAction
    ) {
        self.title = title
        self.description = description
        self.buttonTitle = buttonTitle
        self.skipButtonTitle = skipButtonTitle
        self.action = action
    }
}

public enum TerminationOfferAction: Codable, Sendable, Equatable, Hashable {
    case updateAddress
    case changeTier
}
