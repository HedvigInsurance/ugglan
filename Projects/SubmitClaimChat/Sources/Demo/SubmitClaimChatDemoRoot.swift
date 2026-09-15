import SwiftUI
import hCore
import hCoreUI

/// Hosts the real claim chat against the demo client – used by the SubmitClaimChat example app.
/// Register `ClaimIntentClient`, `hSubmitClaimFileUploadClient` and `DateService` before creating it.
public struct SubmitClaimChatDemoRoot: View {
    @StateObject private var viewModel: SubmitClaimChatViewModel
    private let demoState: String?

    /// `demoState` "text", "textShort" or "voice" opens that input once the first step has been revealed
    /// (launch argument `-demoState voice` in the example scheme).
    public init(demoState: String? = nil) {
        self.demoState = demoState
        _viewModel = StateObject(
            wrappedValue: SubmitClaimChatViewModel(
                startInput: .init(input: .init(type: .regular(hasInProgress: false)), openChat: {})
            )
        )
    }

    public var body: some View {
        SubmitClaimChatScreen()
            .navigationTitle(L10n.claimChatTitle)
            .embededInNavigation(options: [.extendedNavigationWidth], tracking: SubmitClaimChatDemoTracking.root)
            .environmentObject(viewModel)
            .environmentObject(viewModel.scrollCoordinator)
            .task {
                guard let demoState else { return }
                try? await Task.sleep(seconds: 6)
                guard let step = viewModel.currentStep as? SubmitClaimAudioStep else { return }
                switch demoState {
                case "text":
                    step.textInput = "Lorem ipsum dolor sit amet, consectetur adipiscing elit"
                    step.presentTextInput()
                case "textShort":
                    step.textInput = "The fir"
                    step.presentTextInput()
                case "textGrow":
                    // Card grows while open (same path as the validation message appearing).
                    step.textInput = "The fir"
                    step.presentTextInput()
                    try? await Task.sleep(seconds: 3)
                    step.textInput =
                        "The fire started in the kitchen on Tuesday evening while we were out, and the smoke damaged the hallway and the living room ceiling."
                case "textSend":
                    step.textInput = "Lorem ipsum dolor sit amet, consectetur adipiscing elit"
                    step.presentTextInput()
                    try? await Task.sleep(seconds: 3)
                    step.submitResponse()
                case "voice":
                    step.presentAudioInput()
                default:
                    break
                }
            }
    }
}

private enum SubmitClaimChatDemoTracking: TrackingViewNameProtocol {
    case root

    var nameForTracking: String {
        String(describing: SubmitClaimChatScreen.self)
    }
}
