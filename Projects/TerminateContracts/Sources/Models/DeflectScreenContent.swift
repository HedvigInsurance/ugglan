import Foundation
import hCore

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
            return .autoCancel(message: L10n.terminationFlowAutoCancelSoldMessage)
        case .autoCancelScrapped:
            return .autoCancel(message: L10n.terminationFlowAutoCancelScrappedMessage)
        case .autoCancelDecommission:
            return .autoCancel(message: L10n.terminationFlowAutoCancelDecommissionMessage)
        case .autoDecommission:
            return DeflectScreenContent(
                title: L10n.terminationFlowAutoDecomTitle,
                message: L10n.terminationFlowAutoDecomInfo,
                extraMessage: nil,
                explanations: [
                    ExplanationItem(
                        title: L10n.terminationFlowAutoDecomCoveredTitle,
                        text: L10n.terminationFlowAutoDecomCoveredInfo
                    ),
                    ExplanationItem(
                        title: L10n.terminationFlowAutoDecomCostsTitle,
                        text: L10n.terminationFlowAutoDecomCostsInfo
                    ),
                ],
                info: L10n.terminationFlowAutoDecomNotification,
                canContinueTermination: true
            )
        case .carAlreadyDecommission:
            return DeflectScreenContent(
                title: L10n.terminationFlowCarBackTitle,
                message: L10n.terminationFlowCarBackMessage,
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
            title: L10n.terminationFlowAutoCancelTitle,
            message: message,
            extraMessage: L10n.terminationFlowAutoCancelAbout,
            explanations: [],
            info: nil,
            canContinueTermination: true
        )
    }
}
