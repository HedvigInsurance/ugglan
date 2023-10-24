import Presentation
import SwiftUI
import hCore
import hCoreUI

struct CoInsuredProcessingScreen: View {
    @StateObject var vm = ProcessingViewModel()
    @State var successViewHidden = true

    var body: some View {
        BlurredProgressOverlay {
            loadingView
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.successViewHidden = false
                    }
                }
            if !successViewHidden {
                successView
            }
            //            PresentableLoadingStoreLens(
            //                ContractStore.self,
            //                loadingState: .postCoInsured
            //            ) {
            //                loadingView
            //            } error: { error in
            //                errorView
            //            } success: {
            //                successView
            //            }
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
                        hText("Co-insured updated")
                        hText("Your insurance will be updated starting from 16 nov 2023")
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
                } content: {
                    hText(L10n.generalDoneButton)
                }
            }
            .sectionContainerStyle(.transparent)

        }
    }

    private var errorView: some View {
        ZStack {
            BackgroundView().ignoresSafeArea()
            RetryView(
                subtitle: L10n.General.errorBody
            ) {
                //                vm.store.send(.postTravelInsuranceForm)
            }
        }
    }

    private var loadingView: some View {
        VStack {
            Spacer()
            Spacer()
            hText("Making changes...")
            ProgressView(value: vm.progress)
                .tint(hTextColor.primary)
                .frame(width: UIScreen.main.bounds.width * 0.53)
            Spacer()
            Spacer()
            Spacer()
        }
    }
}

class ProcessingViewModel: ObservableObject {
    @Published var progress: Float = 0
    @PresentableStore var store: ContractStore
}

struct SuccessScreen_Previews: PreviewProvider {
    static var previews: some View {
        CoInsuredProcessingScreen()
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
