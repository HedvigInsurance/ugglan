import SwiftUI
import hCore
import hCoreUI

struct CoInsuredInputErrorView: View {
    @ObservedObject var vm: CoInusuredInputViewModel
    @ObservedObject private var editCoInsuredNavigation: EditCoInsuredNavigationViewModel
    @ObservedObject private var intentViewModel: IntentViewModel
    let showEnterManuallyButton: Bool

    init(
        vm: CoInusuredInputViewModel,
        editCoInsuredNavigation: EditCoInsuredNavigationViewModel,
        showEnterManuallyButton: Bool
    ) {
        self.editCoInsuredNavigation = editCoInsuredNavigation
        self.vm = vm
        self.intentViewModel = editCoInsuredNavigation.intentViewModel
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
                ?? intentViewModel.errorMessageForCoinsuredList,
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
                            if self.showEnterManuallyButton {
                                vm.noSSN = true
                            }
                            vm.SSNError = nil
                            intentViewModel.errorMessageForInput = nil
                            intentViewModel.errorMessageForCoinsuredList = nil
                            intentViewModel.viewState = .success
                        }
                    }
                ),
                dismissButton: .init(
                    buttonTitle: L10n.generalCancelButton,
                    buttonAction: {
                        vm.SSNError = nil
                        intentViewModel.errorMessageForInput = nil
                        intentViewModel.errorMessageForCoinsuredList = nil
                        intentViewModel.viewState = .success
                    }
                )
            )
        )
    }
}

#Preview {
    CoInsuredInputErrorView(
        vm: CoInusuredInputViewModel(
            coInsuredModel: CoInsuredModel(),
            actionType: .add,
            contractId: ""
        ),
        editCoInsuredNavigation: .init(config: .init()),
        showEnterManuallyButton: false
    )
}
