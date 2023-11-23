import Presentation
import SwiftUI
import hCore
import hCoreUI

struct CoInsuredProcessingScreen: View {
    @StateObject var vm = ProcessingViewModel()
    @ObservedObject var intentVm: IntentViewModel
    var showSuccessScreen: Bool
    @PresentableStore var store: ContractStore

    init(
        showSuccessScreen: Bool
    ) {
        self.showSuccessScreen = showSuccessScreen
        let store: ContractStore = globalPresentableStoreContainer.get()
        intentVm = store.intentViewModel
    }

    var body: some View {
        BlurredProgressOverlay {
            PresentableLoadingStoreLens(
                ContractStore.self,
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
            VStack {
                Spacer()
                Spacer()
                VStack(spacing: 16) {
                    Image(uiImage: hCoreUIAssets.warningTriangleFilled.image)
                        .foregroundColor(hSignalColor.amberElement)
                    VStack(spacing: 0) {
                        hText(L10n.somethingWentWrong)
                            .foregroundColor(hTextColor.primaryTranslucent)
                        hText(L10n.General.errorBody)
                            .foregroundColor(hTextColor.secondaryTranslucent)
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
                    missingContractAlert()
                } content: {
                    hText(L10n.generalCancelButton)
                }
            }
            .sectionContainerStyle(.transparent)
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
            let missingContract = store.state.activeContracts.first { contract in
                if contract.upcomingChangedAgreement != nil {
                    return false
                } else {
                    return contract.currentAgreement?.coInsured
                        .first(where: { coInsured in
                            coInsured.hasMissingInfo && contract.terminationDate == nil
                        }) != nil
                }
            }
            if missingContract != nil {
                vm.store.send(
                    .coInsuredNavigationAction(
                        action: .openMissingCoInsuredAlert(contractId: missingContract?.id ?? "")
                    )
                )
            }
        }
    }

}

class ProcessingViewModel: ObservableObject {
    @Published var progress: Float = 0
    @PresentableStore var store: ContractStore
}

struct SuccessScreen_Previews: PreviewProvider {
    static var previews: some View {
        CoInsuredProcessingScreen(showSuccessScreen: true)
            .onAppear {
                let store: ContractStore = globalPresentableStoreContainer.get()
                store.setLoading(for: .postCoInsured)
                store.setError("error", for: .postCoInsured)
            }
    }
}
struct BackgroundView: UIViewRepresentable {

    func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.backgroundColor = .brand(.primaryBackground())
    }

    func makeUIView(context: Context) -> some UIView {
        UIView()
    }
}
