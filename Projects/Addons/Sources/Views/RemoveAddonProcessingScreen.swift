import SwiftUI
import hCore
import hCoreUI

struct RemoveAddonProcessingView: View {
    @EnvironmentObject var navigationVm: RemoveAddonNavigationViewModel
    @ObservedObject var vm: RemoveAddonViewModel

    var body: some View {
        ProcessingStateView(
            loadingViewText: L10n.tierFlowCommitProcessingLoadingTitle,
            successViewTitle: L10n.addonFlowSuccessTitle,
            successViewBody: L10n.addonFlowSuccessSubtitle(
                navigationVm.removeAddonVm.removeOffer?.activationDate.displayDateDDMMMYYYYFormat ?? ""
            ),
            successViewButtonAction: {
                navigationVm.router.dismiss(withDismissingAll: true)
            },
            state: $vm.submittingState
        )
        .hStateViewButtonConfig(
            .init(
                actionButton: .init { navigationVm.isProcessingPresented = false },
                dismissButton: .init(
                    buttonTitle: L10n.generalCancelButton,
                    buttonAction: { navigationVm.router.dismiss(withDismissingAll: true) }
                )
            )
        )
        .onDeinit { [weak vm] in
            if vm?.submittingState == .success {
                Task { NotificationCenter.default.post(name: .addonsChanged, object: nil) }
            }
        }
    }
}
