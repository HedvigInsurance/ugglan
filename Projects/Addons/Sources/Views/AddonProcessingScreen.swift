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
                vm.addonOffer?.activationDate?.displayDateDDMMMYYYYFormat ?? ""
            ),
            successViewButtonAction: {
                addonNavigationVm.router.dismiss(withDismissingAll: true)
            },
            state: $vm.submittingAddonsViewState
        )
        .hStateViewButtonConfig(errorButtons)
    }

    private var errorButtons: StateViewButtonConfig {
        .init(
            actionButton: .init(
                buttonAction: {
                    Task {
                        await addonNavigationVm.changeAddonVm!.submitAddons()
                    }
                }
            ),
            dismissButton:
                .init(
                    buttonTitle: L10n.generalCloseButton,
                    buttonAction: {
                        addonNavigationVm.router.dismiss(withDismissingAll: true)
                    }
                )
        )
    }
}

struct AddonProcessingScreen_Previews: PreviewProvider {
    static var previews: some View {
        Dependencies.shared.add(module: Module { () -> AddonsClient in AddonsClientDemo() })
        return AddonProcessingScreen(
            vm: .init(contractId: ""),
            addonNavigationVm: .init()
        )
    }
}
