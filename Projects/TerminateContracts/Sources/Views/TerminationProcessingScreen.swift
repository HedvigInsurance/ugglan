import hCore
import hCoreUI
import SwiftUI

struct TerminationProcessingScreen: View {
    @ObservedObject var terminationNavigationVm: TerminationFlowNavigationViewModel

    var body: some View {
        ProcessingStateView(
            loadingViewText: L10n.terminateContractTerminatingProgress,
            state: $terminationNavigationVm.confirmTerminationState,
            duration: 3
        )
        .hStateViewButtonConfig(
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

#Preview {
    TerminationProcessingScreen(terminationNavigationVm: .init(configs: [], terminateInsuranceViewModel: nil))
}
