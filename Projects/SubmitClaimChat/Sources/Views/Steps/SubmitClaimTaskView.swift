import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimTaskView: View {
    @ObservedObject var viewModel: SubmitClaimTaskStep
    var body: some View {
        if viewModel.error != nil {
            hText(viewModel.taskModel.description)
        }
    }
}

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
                        ProgressView()
                            .tint(hSignalColor.Green.element)
                    }
                }
            hText(viewModel.claimIntent.currentStep.text, style: .label)
        }
        .hPillStyle(color: .grey)
    }
}

#Preview {
    let demo = ClaimIntentClientDemo()
    Dependencies.shared.add(module: Module { () -> ClaimIntentClient in demo })
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    let model = ClaimIntentClientDemo().taskDemoStep
    return VStack {
        SubmitClaimTaskResultView(viewModel: model)
        Spacer()
        SubmitClaimTaskView(viewModel: model)
    }
}
