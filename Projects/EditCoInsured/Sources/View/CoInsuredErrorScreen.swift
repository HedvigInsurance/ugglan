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
        hForm {
            VStack(spacing: 16) {
                Image(uiImage: hCoreUIAssets.warningTriangleFilled.image)
                    .foregroundColor(hSignalColor.amberElement)

                VStack {
                    hText(L10n.somethingWentWrong)
                        .foregroundColor(hTextColor.primaryTranslucent)
                    hText(vm.SSNError ?? intentVm.errorMessageForInput ?? intentVm.errorMessageForCoinsuredList ?? "")
                        .foregroundColor(hTextColor.secondaryTranslucent)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }
            }
            .padding(.bottom, 32)
        }
        .hFormAttachToBottom {
            VStack(spacing: 8) {
                if vm.enterManually {
                    hButton.LargeButton(type: .primary) {
                        vm.SSNError = nil
                        vm.noSSN = true
                    } content: {
                        hText(L10n.coinsuredEnterManuallyButton)
                    }
                } else {
                    hButton.LargeButton(type: .primary) {
                        vm.SSNError = nil
                        intentVm.errorMessageForInput = nil
                        intentVm.errorMessageForCoinsuredList = nil
                    } content: {
                        hText(L10n.generalRetry)
                    }
                }
                hButton.LargeButton(type: .ghost) {
                    vm.SSNError = nil
                    intentVm.errorMessageForInput = nil
                    intentVm.errorMessageForCoinsuredList = nil
                } content: {
                    hText(L10n.generalCancelButton)
                }

            }
            .padding(16)
        }
    }
}
