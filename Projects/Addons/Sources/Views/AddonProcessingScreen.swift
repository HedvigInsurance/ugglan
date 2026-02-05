import SwiftUI
import hCore
import hCoreUI

struct AddonProcessingScreen: View {
    @ObservedObject var vm: ChangeAddonViewModel
    @EnvironmentObject var addonNavigationVm: ChangeAddonNavigationViewModel

    var body: some View {
        ProcessingStateView(
            loadingViewText: L10n.tierFlowCommitProcessingLoadingTitle,
            successViewTitle: L10n.addonFlowSuccessTitle,
            successViewBody: L10n.addonFlowSuccessSubtitle(
                vm.addonOffer?.activationDate.displayDateDDMMMYYYYFormat ?? ""
            ),
            successViewButtonAction: {
                addonNavigationVm.router.dismiss(withDismissingAll: true)
            },
            state: $vm.submittingAddonsViewState
        )
        .hStateViewButtonConfig(errorButtons)
        .onDeinit { [weak vm] in
            if vm?.submittingAddonsViewState == .success {
                Task {
                    NotificationCenter.default.post(
                        name: .addonAdded,
                        object: nil
                    )
                }
            }
        }
    }

    private var errorButtons: StateViewButtonConfig {
        .init(
            actionButton: .init(
                buttonAction: {
                    addonNavigationVm.isAddonProcessingPresented = false
                }
            ),
            dismissButton: .init(
                buttonTitle: L10n.generalCancelButton,
                buttonAction: {
                    addonNavigationVm.router.dismiss(withDismissingAll: true)
                }
            )
        )
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    Dependencies.shared.add(module: Module { () -> AddonsClient in AddonsClientDemo() })
    return AddonProcessingScreen(
        vm: .init(
            config: .init(contractId: "contractId", exposureName: "exposureName", displayName: "displayName"),
            addonSource: .insurances
        ),
        addonNavigationVm: .init()
    )
}
