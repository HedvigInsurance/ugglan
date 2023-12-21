import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct CoInsuredInputErrorView: View {
    @ObservedObject var intentVm: IntentViewModel
    @PresentableStore var store: EditCoInsuredStore
    @ObservedObject var vm: CoInusuredInputViewModel

    public init(
        vm: CoInusuredInputViewModel
    ) {
        let store: EditCoInsuredStore = globalPresentableStoreContainer.get()
        intentVm = store.intentViewModel
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
            description: vm.SSNError ?? intentVm.errorMessageForInput ?? intentVm.errorMessageForCoinsuredList,
            buttons:
                    .init(
                        actionButtonAttachedToBottom: . init(
                            buttonTitle: actionButtonTitle,
                            buttonAction: {
                                if vm.enterManually {
                                    vm.SSNError = nil
                                    vm.noSSN = true
                                } else {
                                    vm.SSNError = nil
                                    intentVm.errorMessageForInput = nil
                                    intentVm.errorMessageForCoinsuredList = nil
                                }
                            }),
                        dismissButton: .init(
                            buttonTitle: L10n.generalCancelButton,
                            buttonAction: {
                                vm.SSNError = nil
                                intentVm.errorMessageForInput = nil
                                intentVm.errorMessageForCoinsuredList = nil
                            })
        )
            )
        .hExtraBottomPadding
    }
}

#Preview {
    CoInsuredInputErrorView(vm: CoInusuredInputViewModel(
        coInsuredModel: CoInsuredModel(),
        actionType: .add,
        contractId: "")
    )
}
