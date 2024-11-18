import SwiftUI
import hCore
import hCoreUI

struct TerminationProcessingScreen: View {
    @EnvironmentObject var confirmTerminationVm: ConfirmTerminationViewModel

    var body: some View {
        ProcessingStateView(
            loadingViewText: L10n.terminateContractTerminatingProgress,
            state: $confirmTerminationVm.viewState,
            duration: 3
        )
    }
}
