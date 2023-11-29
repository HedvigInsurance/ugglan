import Presentation
import SwiftUI
import hCore
import hCoreUI

struct CoInsuredErrorScreen: View {
    @PresentableStore var store: ContractStore

    var body: some View {
        hForm {
            VStack(spacing: 16) {
                Image(uiImage: hCoreUIAssets.infoIcon.image)
                    .foregroundColor(hSignalColor.blueElement)
                VStack {
                    hText(L10n.somethingWentWrong)
                        .foregroundColor(hTextColor.primaryTranslucent)
                    hText(L10n.coinsuredErrorText)
                        .foregroundColor(hTextColor.secondaryTranslucent)
                }
                hButton.MediumButton(type: .primary) {
                    store.send(.goToFreeTextChat)
                } content: {
                    hText(L10n.openChat)
                }
            }
            .padding(.horizontal, 16)
        }
        .hFormAttachToBottom {
            hButton.LargeButton(type: .ghost) {
                store.send(.coInsuredNavigationAction(action: .dismissEditCoInsuredFlow))
            } content: {
                hText(L10n.generalCancelButton)
            }
        }
        .padding(.horizontal, 16)
    }
}

public struct CoInsuredInputErrorView: View {
    @ObservedObject var intentVm: IntentViewModel
    @PresentableStore var store: ContractStore
    @ObservedObject var vm: CoInusuredInputViewModel

    public init(
        vm: CoInusuredInputViewModel
    ) {
        let store: ContractStore = globalPresentableStoreContainer.get()
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
                    hText(vm.SSNError ?? intentVm.errorMessage ?? "")
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
                        vm.showErrorView = false
                        vm.noSSN = true
                    } content: {
                        hText(L10n.coinsuredEnterManuallyButton)
                    }
                } else {
                    hButton.LargeButton(type: .primary) {
                        vm.showErrorView = false
                        intentVm.showErrorView = false
                    } content: {
                        hText(L10n.generalRetry)
                    }
                }
                hButton.LargeButton(type: .ghost) {
                    vm.showErrorView = false
                    intentVm.showErrorView = false
                } content: {
                    hText(L10n.generalCancelButton)
                }

            }
            .padding(16)
        }
    }
}

struct CoInsuredErrorScreen_Previews: PreviewProvider {
    static var previews: some View {
        CoInsuredErrorScreen()
    }
}
