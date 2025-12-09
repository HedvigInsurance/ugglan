import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimTaskResultView: View {
    @ObservedObject var viewModel: SubmitClaimTaskStep
    var body: some View {
        HStack {
            hCoreUIAssets.checkmark.view
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(hSignalColor.Green.element)
                .opacity(viewModel.taskModel.isCompleted ? 1 : 0)
                .overlay {
                    if !viewModel.taskModel.isCompleted {
                        CircularProgressView()
                    }
                }
            hText(viewModel.taskModel.description, style: .label)
                .animation(.easeInOut, value: viewModel.taskModel)
        }
        .clipped()
        .hPillStyle(color: .grey)
        .hFieldSize(.capsuleShape)
        .animation(.easeInOut, value: viewModel.taskModel)
    }
}

#Preview {
    let demo = ClaimIntentClientDemo()
    Dependencies.shared.add(module: Module { () -> ClaimIntentClient in demo })
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    let model = ClaimIntentClientDemo().taskDemoStep
    return SubmitClaimTaskResultView(viewModel: model)
}
