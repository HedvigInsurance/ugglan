import EditCoInsuredShared
import SwiftUI
import hCore
import hCoreUI

struct CoInsuredInputErrorView: View {
    @ObservedObject var vm: CoInusuredInputViewModel
    @ObservedObject private var editCoInsuredNavigation: EditCoInsuredNavigationViewModel
    @ObservedObject private var intentViewModel: IntentViewModel
    init(
        vm: CoInusuredInputViewModel,
        editCoInsuredNavigation: EditCoInsuredNavigationViewModel
    ) {
        self.editCoInsuredNavigation = editCoInsuredNavigation
        self.vm = vm
        intentViewModel = editCoInsuredNavigation.intentViewModel
    }

    @ViewBuilder
    var body: some View {
        var actionButtonTitle: String {
            if vm.enterManually {
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
                            vm.SSNError = nil
                            intentViewModel.errorMessageForInput = nil
                            intentViewModel.errorMessageForCoinsuredList = nil
                        }
                    }
                ),
                dismissButton: .init(
                    buttonTitle: L10n.generalCancelButton,
                    buttonAction: {
                        vm.SSNError = nil
                        intentViewModel.errorMessageForInput = nil
                        intentViewModel.errorMessageForCoinsuredList = nil
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
        editCoInsuredNavigation: .init(config: .init())
    )
}
