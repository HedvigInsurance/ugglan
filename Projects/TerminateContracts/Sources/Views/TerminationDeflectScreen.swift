import SwiftUI
import hCore
import hCoreUI

struct TerminationDeflectScreen: View {
    @EnvironmentObject var router: Router
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
                content: .init(title: L10n.terminationFlowIUnderstandText)
            ) { [weak router] in
                router?.dismiss()
            }

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
        }
    }

    private func subtitleLabel(for text: String) -> some View {
        hText(text)
            .foregroundColor(hTextColor.Translucent.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview("Auto Cancel"){
    TerminationDeflectScreen(
        content: DeflectScreenContent.from(suggestionType: .autoCancelSold)!
    )
    .environmentObject(Router())
    .environmentObject(
        TerminationFlowNavigationViewModel(
            configs: [],
            terminateInsuranceViewModel: nil
        )
    )
}

#Preview("Auto Decom"){
    TerminationDeflectScreen(
        content: DeflectScreenContent.from(suggestionType: .autoDecommission)!
    )
    .environmentObject(Router())
    .environmentObject(
        TerminationFlowNavigationViewModel(
            configs: [],
            terminateInsuranceViewModel: nil
        )
    )
}

#Preview("Recommission"){
    TerminationDeflectScreen(
        content: DeflectScreenContent.from(suggestionType: .carAlreadyDecommission)!
    )
    .environmentObject(Router())
    .environmentObject(
        TerminationFlowNavigationViewModel(
            configs: [],
            terminateInsuranceViewModel: nil
        )
    )
}
