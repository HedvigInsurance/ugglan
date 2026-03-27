import Foundation
import hCore

public struct DeflectScreenContent: Equatable, Hashable, Sendable {
    let title: String
    let message: String
    let extraMessage: String?
    let explanations: [ExplanationItem]
    let info: String?
    let primaryButtonTitle: String
    let primaryAction: DeflectScreenPrimaryAction
    let canContinueTermination: Bool

    public init(
        title: String,
        message: String,
        extraMessage: String?,
        explanations: [ExplanationItem],
        info: String?,
        primaryButtonTitle: String,
        primaryAction: DeflectScreenPrimaryAction,
        canContinueTermination: Bool
    ) {
        self.title = title
        self.message = message
        self.extraMessage = extraMessage
        self.explanations = explanations
        self.info = info
        self.primaryButtonTitle = primaryButtonTitle
        self.primaryAction = primaryAction
        self.canContinueTermination = canContinueTermination
    }
}

public enum DeflectScreenPrimaryAction: Equatable, Hashable, Sendable {
    case dismiss
    case openMoveFlow
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
    static func from(suggestion: TerminationSuggestion) -> DeflectScreenContent? {
        switch suggestion.type {
        case .updateAddress:
            return DeflectScreenContent(
                title: L10nDerivation(
                    table: "Localizable",
                    key: "termination_flow.move_deflect.title",
                    args: []
                )
                .render(),
                message: suggestion.description,
                extraMessage: L10nDerivation(
                    table: "Localizable",
                    key: "termination_flow.move_deflect.description",
                    args: []
                )
                .render(),
                explanations: [],
                info: nil,
                primaryButtonTitle: L10n.terminationFlowSuggestionUpdateAddress,
                primaryAction: .openMoveFlow,
                canContinueTermination: true
            )
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
                primaryButtonTitle: L10n.terminationFlowIUnderstandText,
                primaryAction: .dismiss,
                canContinueTermination: true
            )
        case .carAlreadyDecommission:
            return DeflectScreenContent(
                title: L10n.terminationFlowCarBackTitle,
                message: L10n.terminationFlowCarBackMessage,
                extraMessage: nil,
                explanations: [],
                info: nil,
                primaryButtonTitle: L10n.terminationFlowIUnderstandText,
                primaryAction: .dismiss,
                canContinueTermination: true
            )
        case .upgradeCoverage, .downgradePrice, .redirect, .info, .unknown:
            return nil
        }
    }

    static func from(suggestionType: TerminationSuggestionType) -> DeflectScreenContent? {
        from(suggestion: .init(type: suggestionType, description: "", url: nil))
    }

    private static func autoCancel(message: String) -> DeflectScreenContent {
        DeflectScreenContent(
            title: L10n.terminationFlowAutoCancelTitle,
            message: message,
            extraMessage: L10n.terminationFlowAutoCancelAbout,
            explanations: [],
            info: nil,
            primaryButtonTitle: L10n.terminationFlowIUnderstandText,
            primaryAction: .dismiss,
            canContinueTermination: false
        )
    }
}
