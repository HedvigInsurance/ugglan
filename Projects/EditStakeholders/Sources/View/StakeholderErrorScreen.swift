import SwiftUI
import hCore
import hCoreUI

struct StakeholderInputErrorView: View {
    @ObservedObject var vm: StakeholderInputViewModel
    @ObservedObject private var intentViewModel: IntentViewModel
    let showEnterManuallyButton: Bool

    init(
        vm: StakeholderInputViewModel,
        editStakeholdersNavigation: EditStakeholdersNavigationViewModel,
        showEnterManuallyButton: Bool
    ) {
        self.vm = vm
        intentViewModel = editStakeholdersNavigation.intentViewModel
        self.showEnterManuallyButton = showEnterManuallyButton
    }

    @ViewBuilder
    var body: some View {
        var actionButtonTitle: String {
            if showEnterManuallyButton {
                return L10n.coinsuredEnterManuallyButton
            }
            return L10n.generalRetry
        }

        GenericErrorView(
            description: vm.SSNError ?? intentViewModel.errorMessageForInput
                ?? intentViewModel.errorMessageForStakeholderList,
            formPosition: .compact
        )
        .hStateViewButtonConfig(
            .init(
                actionButtonAttachedToBottom: .init(
                    buttonTitle: actionButtonTitle,
                    buttonAction: {
                        if vm.enterManually {
                            vm.SSNError = nil
                            vm.noSSN = true
                        } else {
                            if showEnterManuallyButton {
                                vm.noSSN = true
                            }
                            vm.SSNError = nil
                            intentViewModel.errorMessageForInput = nil
                            intentViewModel.errorMessageForStakeholderList = nil
                            intentViewModel.viewState = .success
                        }
                    }
                ),
                dismissButton: .init(
                    buttonTitle: L10n.generalCancelButton,
                    buttonAction: {
                        vm.SSNError = nil
                        intentViewModel.errorMessageForInput = nil
                        intentViewModel.errorMessageForStakeholderList = nil
                        intentViewModel.viewState = .success
                    }
                )
            )
        )
    }
}

#Preview {
    StakeholderInputErrorView(
        vm: StakeholderInputViewModel(
            stakeholderModel: Stakeholder(),
            actionType: .add,
            contractId: ""
        ),
        editStakeholdersNavigation: .init(config: .init(stakeholderType: .coInsured)),
        showEnterManuallyButton: false
    )
}
