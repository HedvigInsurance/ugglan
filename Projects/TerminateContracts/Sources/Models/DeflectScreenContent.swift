import Foundation

public struct DeflectScreenContent: Equatable, Hashable, Sendable {
    let title: String
    let message: String
    let extraMessage: String?
    let explanations: [ExplanationItem]
    let info: String?
    let canContinueTermination: Bool

    public init(
        title: String,
        message: String,
        extraMessage: String?,
        explanations: [ExplanationItem],
        info: String?,
        canContinueTermination: Bool
    ) {
        self.title = title
        self.message = message
        self.extraMessage = extraMessage
        self.explanations = explanations
        self.info = info
        self.canContinueTermination = canContinueTermination
    }
}

public struct ExplanationItem: Equatable, Hashable, Sendable {
    let title: String
    let text: String

    public init(title: String, text: String) {
        self.title = title
        self.text = text
    }
}

extension DeflectScreenContent {
    static func from(suggestionType: TerminationSuggestionType) -> DeflectScreenContent? {
        switch suggestionType {
        case .autoCancelSold:
            return .autoCancel(
                message: "Since you've sold your car, your insurance will be automatically cancelled."
            )
        case .autoCancelScrapped:
            return .autoCancel(
                message: "Since your car has been scrapped, your insurance will be automatically cancelled."
            )
        case .autoCancelDecommission:
            return .autoCancel(
                message: "Since your car has been decommissioned, your insurance will be automatically cancelled."
            )
        case .autoDecommission:
            return DeflectScreenContent(
                title: "Your insurance will switch to decommission insurance",
                message:
                    "If you've decommissioned your car through Transportstyrelsen, your insurance will automatically switch to decommission insurance.",
                extraMessage: nil,
                explanations: [
                    ExplanationItem(
                        title: "What's covered",
                        text:
                            "The insurance covers damage such as theft, fire, vandalism, and body damage while the car is decommissioned. Legal protection is also included. The insurance is only valid as long as the car remains in Sweden."
                    ),
                    ExplanationItem(
                        title: "What it costs",
                        text: "You'll receive a confirmation email within a few days, where you can see your new price."
                    ),
                ],
                info: "If you don't want to keep your decommission insurance, you can cancel it below.",
                canContinueTermination: true
            )
        case .carAlreadyDecommission:
            return DeflectScreenContent(
                title: "Your car is back on the road",
                message:
                    "Since your car is registered again, your insurance will automatically switch back to your regular coverage.",
                extraMessage: nil,
                explanations: [],
                info: nil,
                canContinueTermination: true
            )
        case .updateAddress, .upgradeCoverage, .downgradePrice, .redirect, .info, .unknown:
            return nil
        }
    }

    private static func autoCancel(message: String) -> DeflectScreenContent {
        DeflectScreenContent(
            title: "We'll cancel your insurance automatically",
            message: message,
            extraMessage:
                "We'll send a cancellation confirmation within a few days. If you don't get it after 5 days, feel free to contact us.",
            explanations: [],
            info: nil,
            canContinueTermination: true
        )
    }
}
