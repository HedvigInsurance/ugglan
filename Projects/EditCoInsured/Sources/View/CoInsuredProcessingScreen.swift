import Presentation
import SwiftUI
import hCore
import hCoreUI

struct CoInsuredProcessingScreen: View {
    @StateObject var vm = ProcessingViewModel()
    @ObservedObject var intentVm: IntentViewModel
    var showSuccessScreen: Bool
    @PresentableStore var store: EditCoInsuredStore
    @EnvironmentObject private var editCoInsuredNavigation: EditCoInsuredNavigationViewModel
    let onDisappear: () -> Void

    init(
        showSuccessScreen: Bool,
        onDisappear: @escaping () -> Void
    ) {
        self.showSuccessScreen = showSuccessScreen
        let store: EditCoInsuredStore = globalPresentableStoreContainer.get()
        intentVm = store.intentViewModel
        self.onDisappear = onDisappear
    }

    var body: some View {
        ProcessingView(
            showSuccessScreen: showSuccessScreen,
            EditCoInsuredStore.self,
            loading: .postCoInsured,
            loadingViewText: L10n.contractAddCoinsuredProcessing,
            successViewTitle: L10n.contractAddCoinsuredUpdatedTitle,
            successViewBody: L10n.contractAddCoinsuredUpdatedLabel(
                intentVm.intent.activationDate.localDateToDate?.displayDateDDMMMYYYYFormat ?? ""
            ),
            successViewButtonAction: {
                missingContractAlert()
            },
            onAppearLoadingView: {
                missingContractAlert()
            },
            onErrorCancelAction: {
                onDisappear()
            }
        )
        .hSuccessBottomAttachedView {
            customBottomSuccessView
        }
    }

    private var customBottomSuccessView: some View {
        hSection {
            hButton.LargeButton(type: .ghost) {
                editCoInsuredNavigation.showProgressScreenWithSuccess = false
                editCoInsuredNavigation.showProgressScreenWithoutSuccess = false
                editCoInsuredNavigation.editCoInsuredConfig = nil
                missingContractAlert()
            } content: {
                hText(L10n.generalDoneButton)
            }
        }
        .sectionContainerStyle(.transparent)
    }

    private func missingContractAlert() {
        vm.store.send(.fetchContracts)
        onDisappear()
    }
}

class ProcessingViewModel: ObservableObject {
    @Published var progress: Float = 0
    @PresentableStore var store: EditCoInsuredStore
}

struct SuccessScreen_Previews: PreviewProvider {
    static var previews: some View {
        CoInsuredProcessingScreen(showSuccessScreen: true, onDisappear: {})
            .onAppear {
                let store: EditCoInsuredStore = globalPresentableStoreContainer.get()
                store.setLoading(for: .postCoInsured)
                store.setError("error", for: .postCoInsured)
            }
    }
}
