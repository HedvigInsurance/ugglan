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
            successViewBody: L10n.addonFlowSuccessSubtitle,
            successViewButtonAction: {
                addonNavigationVm.router.dismiss()
            },
            state: $vm.viewState
        )
        .hErrorViewButtonConfig(errorButtons)
    }

    private var errorButtons: ErrorViewButtonConfig {
        .init(
            actionButton: .init(
                buttonAction: {
                    /* TODO: COMMIT ADDON */
                }
            ),
            dismissButton:
                .init(
                    buttonTitle: L10n.generalCloseButton,
                    buttonAction: {
                        addonNavigationVm.router.dismiss()
                    }
                )
        )
    }
}

struct AddonProcessingScreen_Previews: PreviewProvider {
    static var previews: some View {
        Dependencies.shared.add(module: Module { () -> AddonsClient in AddonsClientDemo() })
        return AddonProcessingScreen(
            vm: .init(contractId: "contractId"),
            addonNavigationVm: .init()
        )
    }
}
