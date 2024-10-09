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
                changeTierNavigationVm.router.dismiss()
            },
            onAppearLoadingView: nil,
            errorViewButtons: .init(
                actionButton: .init(
                    buttonTitle: nil,
                    buttonAction: {
                        vm.commitTier()
                    }
                ),
                dismissButton:
                    .init(
                        buttonTitle: L10n.generalCloseButton,
                        buttonAction: {
                            changeTierNavigationVm.router.dismiss()
                        }
                    )
            ),
            state: $vm.viewState
        )
    }
}

struct ChangeTierProcessingView_Previews: PreviewProvider {
    static var previews: some View {
        Dependencies.shared.add(module: Module { () -> ChangeTierClient in ChangeTierClientDemo() })
        Localization.Locale.currentLocale.send(.sv_SE)
        return ChangeTierProcessingView(
            vm: .init(
                changeTierInput: .init(
                    source: .betterCoverage,
                    contractIds: [
                        .init(
                            contractId: "contractId1",
                            contractDisplayName: "contractDisplayName",
                            contractExposureName: "contractExposureName"
                        )
                    ]
                )
            )
        )
    }
}
