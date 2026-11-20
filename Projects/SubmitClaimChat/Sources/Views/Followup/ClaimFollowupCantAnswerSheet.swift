import Claims
import SwiftUI
import hCore
import hCoreUI

struct ClaimFollowupCantAnswerSheet: View {
    let vm: ClaimFollowupViewModel
    let question: ClaimFollowupQuestion
    let onSkipped: () -> Void
    let onCancel: () -> Void
    @State private var comment: String
    @State private var isLoading = false

    init(
        vm: ClaimFollowupViewModel,
        question: ClaimFollowupQuestion,
        onSkipped: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.vm = vm
        self.question = question
        self.onSkipped = onSkipped
        self.onCancel = onCancel
        _comment = State(initialValue: question.cantAnswerComment ?? "")
    }

    var body: some View {
        hForm {
            hSection {
                VStack(spacing: .padding16) {
                    InfoCard(text: L10n.claimFollowupCantAnswerBody, type: .attention)
                    if question.state == .answered {
                        hText(L10n.claimFollowupCantAnswerDiscard, style: .body1)
                            .foregroundColor(hTextColor.Opaque.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    hFloatingTextField(
                        masking: .init(type: .none),
                        value: $comment,
                        placeholder: L10n.claimFollowupCantAnswerCommentPlaceholder
                    )
                    .hFieldMultiline(true)
                    VStack(spacing: .padding8) {
                        hCancelButton(.primary) { onCancel() }
                        // Skipping is the destructive choice, so it is the quiet red one and staying is the default.
                        hButton(.large, .ghost, content: .init(title: L10n.claimFollowupCantAnswerButton)) {
                            isLoading = true
                            let trimmedComment = comment.trimmingCharacters(in: .whitespacesAndNewlines)
                            let skipped = await vm.cantAnswer(
                                question,
                                comment: trimmedComment.isEmpty ? nil : trimmedComment
                            )
                            isLoading = false
                            if skipped {
                                onSkipped()
                            }
                        }
                        .hCustomButtonView {
                            hText(L10n.claimFollowupCantAnswerButton)
                                .foregroundColor(hSignalColor.Red.text)
                        }
                        .hButtonIsLoading(isLoading)
                    }
                }
            }
            .sectionContainerStyle(.transparent)
        }
        .hFormContentPosition(.compact)
        .navigationTitle(L10n.claimFollowupCantAnswerTitle)
        .disabled(isLoading)
        .embededInNavigation(tracking: String(describing: ClaimFollowupCantAnswerSheet.self))
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> hFetchClaimsClient in FetchClaimsClientDemo() })
    Dependencies.shared.add(module: Module { () -> hClaimFollowupClient in ClaimFollowupClientDemo() })
    let followup = ClaimFollowup.previewFollowup
    return ClaimFollowupCantAnswerSheet(
        vm: ClaimFollowupViewModel(followup: followup),
        question: followup.questions[0],
        onSkipped: {},
        onCancel: {}
    )
}
