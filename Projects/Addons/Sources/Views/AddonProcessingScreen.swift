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
            successViewBody: L10n.addonFlowSuccessSubtitle(vm.activationDate?.displayDateDDMMMYYYYFormat ?? ""),
            successViewButtonAction: {
                addonNavigationVm.router.dismiss()
            },
            state: $vm.submittingAddonsViewState
        )
        .hErrorViewButtonConfig(errorButtons)
    }

    private var errorButtons: ErrorViewButtonConfig {
        .init(
            actionButton: .init(
                buttonAction: {
                    Task {
                        await addonNavigationVm.changeAddonVm.submitAddons()
                    }
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
            vm: .init(),
            addonNavigationVm: .init()
        )
    }
}
