import SwiftUI
import hCoreUI

struct SubmitClaimTaskView: View {
    @ObservedObject var viewModel: SubmitClaimTaskStep
    var body: some View {
        hText(viewModel.taskModel.description)
    }
}
