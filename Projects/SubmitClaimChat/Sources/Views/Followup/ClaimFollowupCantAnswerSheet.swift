import Claims
import SwiftUI
import hCore
import hCoreUI

struct ClaimFollowupCantAnswerSheet: View {
    let vm: ClaimFollowupViewModel
    let question: ClaimFollowupQuestion
    @State private var comment: String
    @State private var isLoading = false

    init(vm: ClaimFollowupViewModel, question: ClaimFollowupQuestion) {
        self.vm = vm
        self.question = question
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
                        hButton(.large, .primary, content: .init(title: L10n.claimFollowupCantAnswerButton)) {
                            isLoading = true
                            let trimmedComment = comment.trimmingCharacters(in: .whitespacesAndNewlines)
                            await vm.cantAnswer(question, comment: trimmedComment.isEmpty ? nil : trimmedComment)
                            isLoading = false
                        }
                        .hButtonIsLoading(isLoading)
                        hCancelButton { vm.cantAnswerQuestion = nil }
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
        question: followup.questions[0]
    )
}
