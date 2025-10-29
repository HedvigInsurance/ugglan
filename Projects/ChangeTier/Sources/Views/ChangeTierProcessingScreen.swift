import CrossSell
import SwiftUI
import hCore
import hCoreUI

struct ChangeTierProcessingView: View {
    @ObservedObject var vm: ChangeTierViewModel
    @EnvironmentObject var changeTierNavigationVm: ChangeTierNavigationViewModel

    var body: some View {
        ProcessingStateView(
            loadingViewText: L10n.tierFlowCommitProcessingLoadingTitle,
            successViewTitle: L10n.tierFlowCommitProcessingTitle,
            successViewBody: L10n.tierFlowCommitProcessingDescription(
                vm.activationDate?.displayDateDDMMMYYYYFormat ?? ""
            ),
            successViewButtonAction: {
                changeTierNavigationVm.onChangedTier()
                changeTierNavigationVm.router.dismiss()
            },
            state: $vm.viewState
        )
        .hStateViewButtonConfig(errorButtons)
        .onDeinit { [weak vm] in
            if vm?.viewState == .success {
                NotificationCenter.default.post(
                    name: .openCrossSell,
                    object: CrossSellInfo(type: .changeTier)
                )
            }
        }
    }

    private var errorButtons: StateViewButtonConfig {
        .init(
            actionButton: .init(
                buttonAction: {
                    changeTierNavigationVm.router.pop()
                }
            ),
            dismissButton:
                .init(
                    buttonAction: {
                        changeTierNavigationVm.router.dismiss()
                    }
                )
        )
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    Dependencies.shared.add(module: Module { () -> ChangeTierClient in ChangeTierClientDemo() })
    Localization.Locale.currentLocale.send(.sv_SE)
    return ChangeTierProcessingView(
        vm: .init(
            changeTierInput: .contractWithSource(data: .init(source: .betterPrice, contractId: "contractId"))
        )
    )
}
