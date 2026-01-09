import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimHonestyPledgeView: View {
    @ObservedObject var submitClaimChatViewModel: SubmitClaimChatViewModel
    @ObservedObject var viewModel: SubmitClaimHonestyPledgeStep
    @EnvironmentObject var router: Router

    var body: some View {
        hSection {
            VStack(spacing: .padding8) {
                hButton(.large, .primary, content: .init(title: L10n.claimsPledgeSlideLabel)) {
                    viewModel.startFlow()
                    submitClaimChatViewModel.startClaimIntent()
                }
                hCancelButton {
                    router.dismiss()
                }
            }
        }
        .sectionContainerStyle(.transparent)
    }
}

struct SubmitClaimHonestyPledgeResultView: View {
    var body: some View {
        hPill(
            text: L10n.claimsPledgeSlideLabel,
            color: .grey
        )
        .hFieldSize(.capsuleShape)
        .accessibilityLabel(L10n.claimsPledgeSlideLabel)
    }
}

#Preview {
}
