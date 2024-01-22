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
        BlurredProgressOverlay {
            PresentableLoadingStoreLens(
                EditCoInsuredStore.self,
                loadingState: .postCoInsured
            ) {
                loadingView
            } error: { error in
                errorView
            } success: {
                if showSuccessScreen {
                    successView
                } else {
                    loadingView
                        .onAppear {
                            missingContractAlert()
                        }
                }
            }
        }
        .presentableStoreLensAnimation(.default)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                withAnimation(.easeInOut(duration: 1.25)) {
                    vm.progress = 1
                }
            }
        }
    }

    private var successView: some View {
        ZStack(alignment: .bottom) {
            BackgroundView().ignoresSafeArea()
            VStack {
                Spacer()
                Spacer()
                VStack(spacing: 16) {
                    Image(uiImage: hCoreUIAssets.tick.image)
                        .foregroundColor(hSignalColor.greenElement)
                    VStack(spacing: 0) {
                        hText(L10n.contractAddCoinsuredUpdatedTitle)
                        hText(
                            L10n.contractAddCoinsuredUpdatedLabel(
                                intentVm.activationDate.localDateToDate?.displayDateDDMMMYYYYFormat ?? ""
                            )
                        )
                        .foregroundColor(hTextColor.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                    }
                    .padding(.horizontal, 16)
                }
                Spacer()
                Spacer()
                Spacer()
            }
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
    }

    private var errorView: some View {
        ZStack(alignment: .bottom) {
            BackgroundView().ignoresSafeArea()
            GenericErrorView(
                buttons: .init(
                    dismissButton: .init(
                        buttonTitle: L10n.generalCancelButton,
                        buttonAction: {
                            missingContractAlert()
                        }
                    )
                )
            )
        }
    }

    private var loadingView: some View {
        VStack {
            Spacer()
            Spacer()
            hText(L10n.contractAddCoinsuredProcessing)
            ProgressView(value: vm.progress)
                .tint(hTextColor.primary)
                .frame(width: UIScreen.main.bounds.width * 0.53)
            Spacer()
            Spacer()
            Spacer()
        }
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
