import SwiftUI
import hCoreUI

struct SubmitClaimTaskView: View {
    @EnvironmentObject var viewModel: SubmitClaimTaskStep
    var body: some View {
        hText(viewModel.taskModel.description)
    }
}
