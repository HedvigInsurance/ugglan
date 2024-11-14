import EditCoInsuredShared
import SwiftUI
import hCore
import hCoreUI

public struct CoInsuredInputErrorView: View {
    @ObservedObject var vm: CoInusuredInputViewModel
    @ObservedObject private var editCoInsuredNavigation: EditCoInsuredNavigationViewModel

    public init(
        vm: CoInusuredInputViewModel,
        editCoInsuredNavigation: EditCoInsuredNavigationViewModel
    ) {
        self.editCoInsuredNavigation = editCoInsuredNavigation
        self.vm = vm
    }

    @ViewBuilder
    public var body: some View {
        var actionButtonTitle: String {
            if vm.enterManually {
                return L10n.coinsuredEnterManuallyButton
            }
            return L10n.generalRetry
        }

        GenericErrorView(
            description: vm.SSNError ?? editCoInsuredNavigation.intentViewModel.errorMessageForInput
                ?? editCoInsuredNavigation.intentViewModel.errorMessageForCoinsuredList,
            useForm: true
        )
        .hErrorViewButtonConfig(
            .init(
                actionButtonAttachedToBottom: .init(
                    buttonTitle: actionButtonTitle,
                    buttonAction: {
                        if vm.enterManually {
                            vm.SSNError = nil
                            vm.noSSN = true
                        } else {
                            vm.SSNError = nil
                            editCoInsuredNavigation.intentViewModel.errorMessageForInput = nil
                            editCoInsuredNavigation.intentViewModel.errorMessageForCoinsuredList = nil
                        }
                    }
                ),
                dismissButton: .init(
                    buttonTitle: L10n.generalCancelButton,
                    buttonAction: {
                        vm.SSNError = nil
                        editCoInsuredNavigation.intentViewModel.errorMessageForInput = nil
                        editCoInsuredNavigation.intentViewModel.errorMessageForCoinsuredList = nil
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
