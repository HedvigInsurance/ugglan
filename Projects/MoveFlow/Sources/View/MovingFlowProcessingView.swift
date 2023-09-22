import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct MovingFlowProcessingView: View {
    @StateObject var vm = ProcessingViewModel()
    var body: some View {
        BlurredProgressOverlay {
            PresentableLoadingStoreLens(
                MoveFlowStore.self,
                loadingState: .confirmMoveIntent
            ) {
                loadingView
            } error: { error in
                errorView
            } success: {
                successView
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
                        .foregroundColor(hSignalColorNew.greenElement)
                    VStack(spacing: 0) {
                        hText(L10n.changeAddressSuccessTitle)
                        hText(L10n.changeAddressSuccessSubtitle(vm.store.state.movingFlowModel?.movingDate ?? ""))
                            .foregroundColor(hTextColorNew.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 16)
                }
                Spacer()
                Spacer()
                Spacer()
            }
            hSection {
                VStack(spacing: 8) {
                    hButton.LargeButton(type: .ghost) {
                        vm.store.send(.navigation(action: .dismissMovingFlow))
                    } content: {
                        hText(L10n.generalCloseButton)
                    }
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
                vm.store.send(.navigation(action: .goBack))
            }
        }
    }

    private var loadingView: some View {
        VStack {
            Spacer()
            Spacer()
            hText(L10n.changeAddressMakingChanges)
            ProgressView(value: vm.progress)
                .tint(hTextColorNew.primary)
                .frame(width: UIScreen.main.bounds.width * 0.53)
            Spacer()
            Spacer()
            Spacer()
        }
    }
}

class ProcessingViewModel: ObservableObject {
    @Published var progress: Float = 0
    @PresentableStore var store: MoveFlowStore

}

struct SuccessScreen_Previews: PreviewProvider {
    static var previews: some View {
        MovingFlowProcessingView()
    }
}
struct BackgroundView: UIViewRepresentable {

    func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.backgroundColor = .brandNew(.primaryBackground())
    }

    func makeUIView(context: Context) -> some UIView {
        UIView()
    }
}
