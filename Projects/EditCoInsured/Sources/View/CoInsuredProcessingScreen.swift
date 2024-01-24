import Presentation
import SwiftUI
import hCore
import hCoreUI

struct CoInsuredProcessingScreen: View {
    @StateObject var vm = ProcessingViewModel()
    @ObservedObject var intentVm: IntentViewModel
    var showSuccessScreen: Bool
    @PresentableStore var store: EditCoInsuredStore

    init(
        showSuccessScreen: Bool
    ) {
        self.showSuccessScreen = showSuccessScreen
        let store: EditCoInsuredStore = globalPresentableStoreContainer.get()
        intentVm = store.intentViewModel
    }

    var body: some View {
        ProcessingView(
            showSuccessScreen: showSuccessScreen,
            EditCoInsuredStore.self,
            loading: .postCoInsured,
            loadingViewText: L10n.contractAddCoinsuredProcessing,
            successViewTitle: L10n.contractAddCoinsuredUpdatedTitle,
            successViewBody: L10n.contractAddCoinsuredUpdatedLabel(
                intentVm.activationDate.localDateToDate?.displayDateDDMMMYYYYFormat ?? ""
            ),
            successViewButtonAction: {
                vm.store.send(.coInsuredNavigationAction(action: .dismissEditCoInsuredFlow))
                missingContractAlert()
            },
            onAppearLoadingView: {
                missingContractAlert()
            },
            onErrorCancelAction: {
                store.send(.coInsuredNavigationAction(action: .dismissEdit))
            },
            customBottomSuccessView: customBottomSuccessView
        )
    }

    private var customBottomSuccessView: some View {
        hSection {
            hButton.LargeButton(type: .ghost) {
                vm.store.send(.coInsuredNavigationAction(action: .dismissEditCoInsuredFlow))
                missingContractAlert()
            } content: {
                hText(L10n.generalDoneButton)
            }
        }
        .sectionContainerStyle(.transparent)
    }

    private func missingContractAlert() {
        vm.store.send(.fetchContracts)
        vm.store.send(.coInsuredNavigationAction(action: .dismissEditCoInsuredFlow))
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            store.send(.checkForAlert)
        }
    }

}

class ProcessingViewModel: ObservableObject {
    @Published var progress: Float = 0
    @PresentableStore var store: EditCoInsuredStore
}

struct SuccessScreen_Previews: PreviewProvider {
    static var previews: some View {
        CoInsuredProcessingScreen(showSuccessScreen: true)
            .onAppear {
                let store: EditCoInsuredStore = globalPresentableStoreContainer.get()
                store.setLoading(for: .postCoInsured)
                store.setError("error", for: .postCoInsured)
            }
    }
}
