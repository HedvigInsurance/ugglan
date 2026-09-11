import SwiftUI
import hCore
import hCoreUI

/// Hosts the real claim chat against the demo client – used by the SubmitClaimChat example app.
/// Register `ClaimIntentClient`, `hSubmitClaimFileUploadClient` and `DateService` before creating it.
public struct SubmitClaimChatDemoRoot: View {
    @StateObject private var viewModel: SubmitClaimChatViewModel
    private let demoState: String?

    /// `demoState` "text" or "voice" opens that input once the first step has been revealed
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
                    step.isTextInputPresented = true
                case "voice":
                    step.isAudioInputPresented = true
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
