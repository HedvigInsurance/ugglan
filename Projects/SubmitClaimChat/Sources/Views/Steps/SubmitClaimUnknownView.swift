import SwiftUI
import hCoreUI

struct SubmitClaimOnknownView: View {
    @ObservedObject var viewModel: SubmitClaimUnknownStep

    var body: some View {
        VStack(spacing: .padding16) {
            hText("UNKNOWN STEP")
        }
    }
}
