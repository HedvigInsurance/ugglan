import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimUnknownView: View {
    @ObservedObject var viewModel: SubmitClaimUnknownStep

    var body: some View {
        VStack(spacing: .padding16) {
            hText(L10n.claimChatUnknownStep)
        }
    }
}
