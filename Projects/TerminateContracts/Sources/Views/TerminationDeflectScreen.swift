import SwiftUI
import hCore
import hCoreUI

struct TerminationDeflectScreen: View {
    @EnvironmentObject var router: NavigationRouter
    @EnvironmentObject var terminationFlowNavigationViewModel: TerminationFlowNavigationViewModel
    let content: DeflectScreenContent

    var body: some View {
        hForm {
            VStack(spacing: .padding16) {
                hSection {
                    subtitleLabel(for: content.message)
                }
                if let extraMessage = content.extraMessage {
                    hSection {
                        subtitleLabel(for: extraMessage)
                    }
                }
                ForEach(Array(content.explanations.enumerated()), id: \.offset) { _, explanation in
                    explanationSection(for: explanation)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.vertical, .padding16)
        }
        .hFormTitle(
            title: .init(
                .small,
                .heading2,
                content.title,
                alignment: .leading
            )
        )
        .hFormAlwaysAttachToBottom {
            hSection {
                VStack(spacing: .padding16) {
                    if let info = content.info {
                        InfoCard(text: info, type: .info)
                    }
                    bottomButtons
                }
            }
        }
        .sectionContainerStyle(.transparent)
    }

    private func explanationSection(for item: ExplanationItem) -> some View {
        hSection {
            hText(item.title)
                .frame(maxWidth: .infinity, alignment: .leading)
            subtitleLabel(for: item.text)
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var bottomButtons: some View {
        VStack(spacing: .padding8) {
            hButton(
                .large,
                .primary,
                content: .init(title: content.primaryButtonTitle)
            ) {
                handlePrimaryAction()
            }

            if content.canContinueTermination {
                hButton(
                    .large,
                    .ghost,
                    content: .init(title: L10n.terminationButton)
                ) { [weak terminationFlowNavigationViewModel] in
                    guard let optionId = terminationFlowNavigationViewModel?.selectedOptionId else { return }
                    terminationFlowNavigationViewModel?
                        .proceedAfterSurvey(
                            optionId: optionId,
                            comment: terminationFlowNavigationViewModel?.selectedComment
                        )
                }
            } else {
                hButton(
                    .large,
                    .ghost,
                    content: .init(title: L10n.CrossSell.Info.faqChatButton)
                ) {
                    router.dismiss()
                    NotificationCenter.default.post(name: .openChat, object: ChatType.newConversation)
                }
            }
        }
    }

    private func handlePrimaryAction() {
        switch content.primaryAction {
        case .dismiss:
            router.dismiss()
        case .openMoveFlow:
            terminationFlowNavigationViewModel.openMoveFlow()
        }
    }

    private func subtitleLabel(for text: String) -> some View {
        hText(text)
            .foregroundColor(hTextColor.Translucent.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview("Auto Cancel") {
    TerminationDeflectScreen(
        content: DeflectScreenContent.from(suggestionType: .autoCancelSold)!
    )
    .environmentObject(NavigationRouter())
    .environmentObject(
        TerminationFlowNavigationViewModel(
            configs: [],
            terminateInsuranceViewModel: nil
        )
    )
}

#Preview("Auto Decom") {
    TerminationDeflectScreen(
        content: DeflectScreenContent.from(suggestionType: .autoDecommission)!
    )
    .environmentObject(NavigationRouter())
    .environmentObject(
        TerminationFlowNavigationViewModel(
            configs: [],
            terminateInsuranceViewModel: nil
        )
    )
}

#Preview("Recommission") {
    TerminationDeflectScreen(
        content: DeflectScreenContent.from(suggestionType: .carAlreadyDecommission)!
    )
    .environmentObject(NavigationRouter())
    .environmentObject(
        TerminationFlowNavigationViewModel(
            configs: [],
            terminateInsuranceViewModel: nil
        )
    )
}

#Preview("Move") {
    TerminationDeflectScreen(
        content: DeflectScreenContent.from(
            suggestion: .init(
                type: .updateAddress,
                description: "Vi hjälper dig att flytta med din försäkring till ditt nya boende.",
                url: nil
            )
        )!
    )
    .environmentObject(NavigationRouter())
    .environmentObject(
        TerminationFlowNavigationViewModel(
            configs: [],
            terminateInsuranceViewModel: nil
        )
    )
}
