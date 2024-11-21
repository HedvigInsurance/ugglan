import SwiftUI
import hCore
import hCoreUI

struct TerminationProcessingScreen: View {
    @ObservedObject var terminationNavigationVm: TerminationFlowNavigationViewModel

    var body: some View {
        ProcessingStateView(
            loadingViewText: L10n.terminateContractTerminatingProgress,
            state: $terminationNavigationVm.confirmTerminationState,
            duration: 3
        )
        .hErrorViewButtonConfig(
            .init(
                actionButton:
                    .init(
                        buttonAction: {
                            terminationNavigationVm.router.dismiss()
                        }
                    ),
                dismissButton: .init(
                    buttonTitle: L10n.generalCancelButton,
                    buttonAction: {
                        terminationNavigationVm.router.dismiss()
                    }
                )
            )
        )
    }
}
