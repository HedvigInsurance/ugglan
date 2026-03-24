import SwiftUI
import hCore
import hCoreUI

struct TerminationDeflectScreen: View {
    @EnvironmentObject var router: Router
    @EnvironmentObject var terminationFlowNavigationViewModel: TerminationFlowNavigationViewModel
    let suggestion: TerminationSuggestion

    init(suggestion: TerminationSuggestion) {
        self.suggestion = suggestion
    }

    var body: some View {
        hForm {
            hSection {
                hText(suggestion.description)
                    .foregroundColor(hTextColor.Translucent.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, .padding16)
        }
        .hFormTitle(
            title: .init(
                .small,
                .heading2,
                L10n.terminationFlowCancellationTitle,
                alignment: .leading
            )
        )
        .hFormAlwaysAttachToBottom {
            hSection {
                VStack(spacing: .padding8) {
                    if let urlString = suggestion.url, let url = URL(string: urlString) {
                        hButton(
                            .large,
                            .primary,
                            content: .init(title: L10n.terminationFlowIUnderstandText)
                        ) {
                            UIApplication.shared.open(url)
                        }
                    }

                    hButton(
                        .large,
                        suggestion.url != nil ? .secondary : .primary,
                        content: .init(title: L10n.generalCloseButton)
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
        }
        .sectionContainerStyle(.transparent)
    }
}

#Preview {
    TerminationDeflectScreen(
        suggestion: .init(
            type: .autoDecommission,
            description: "Your car will be automatically decommissioned.",
            url: nil
        )
    )
    .environmentObject(Router())
    .environmentObject(
        TerminationFlowNavigationViewModel(
            configs: [],
            terminateInsuranceViewModel: nil
        )
    )
}
