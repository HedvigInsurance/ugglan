import SwiftUI
import hCore
import hCoreUI

/// Hosts the real claim chat against the demo client – used by the SubmitClaimChat example app.
/// Register `ClaimIntentClient`, `hSubmitClaimFileUploadClient` and `DateService` before creating it.
public struct SubmitClaimChatDemoRoot: View {
    @StateObject private var viewModel: SubmitClaimChatViewModel
    private let demoState: String?

    /// `demoState` "text", "textShort", "textGrow", "textSend", "textCancelSkip" or "voice" drives that input once the
    /// first step has been revealed
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
                await delay(6)
                guard let step = viewModel.currentStep as? SubmitClaimAudioStep else { return }
                switch demoState {
                case "text":
                    step.textInput = "Lorem ipsum dolor sit amet, consectetur adipiscing elit"
                    step.beginText()
                case "textShort":
                    // Too little text: the length message only appears once Skicka is tapped.
                    step.textInput = "The fir"
                    step.beginText()
                    await delay(3)
                    step.saveText()
                case "textGrow":
                    // Card grows while open (same path as the validation message appearing).
                    step.textInput = "The fir"
                    step.beginText()
                    await delay(3)
                    step.textInput =
                        "The fire started in the kitchen on Tuesday evening while we were out, and the smoke damaged the hallway and the living room ceiling."
                case "textSend":
                    step.textInput = "Lorem ipsum dolor sit amet, consectetur adipiscing elit"
                    step.beginText()
                    await delay(3)
                    step.saveText()
                case "textCancelSkip":
                    // Skriv → type → Avbryt → Hoppa över must render the skipped pill, not an empty bubble.
                    step.textInput = "The fire started in the kitchen"
                    step.beginText()
                    await delay(2)
                    step.cancelInput()
                    await delay(2)
                    await step.skip()
                case "voice":
                    step.beginVoice()
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
