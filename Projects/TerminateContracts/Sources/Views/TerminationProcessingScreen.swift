import SwiftUI
import hCore
import hCoreUI

struct TerminationProcessingScreen: View {
    @PresentableStore var store: TerminationContractStore

    var body: some View {
        ProcessingView(
            showSuccessScreen: true,
            TerminationContractStore.self,
            loading: .sendTerminationDate,
            successView: EmptyView(),
            loadingViewText: L10n.terminateContractTerminatingProgress
        )
    }
}

#Preview{
    TerminationProcessingScreen()
}
