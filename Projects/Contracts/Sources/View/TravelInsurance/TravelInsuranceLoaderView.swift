import SwiftUI
import hCore
import Flow
import hCoreUI
import Presentation

struct TravelInsuranceLoadingView<Content: View>: View {
    var content: () -> Content
    @PresentableStore var store: TravelInsuranceStore
    private let action: TravelInsuranceLoadingAction

    @State var presentError = false
    @State var error = ""
    @State var isLoading = false
    private let onError: (() -> Void)?
    var disposeBag = DisposeBag()

    public init(
        onError: (() -> Void)? = nil,
        _ action: TravelInsuranceLoadingAction,
        @ViewBuilder content: @escaping () -> Content
    ) {
        
        self.onError = onError
        self.action = action
        self.content = content
    }
    public var body: some View {
        ZStack {
            content()
                .alert(isPresented: $presentError) {
                    Alert(
                        title: Text(L10n.somethingWentWrong),
                        message: Text(error),
                        dismissButton: .default(Text(L10n.alertOk), action: {
                            store.send(.setLoadingState(action: action, state: nil))
                        })
                    )
                }
            if isLoading {
                HStack {
                    WordmarkActivityIndicator(.standard)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(hBackgroundColor.primary.opacity(0.7))
                .cornerRadius(.defaultCornerRadius)
                .edgesIgnoringSafeArea(.top)
            }
        }
        .onAppear {
            func handle(state: TravelInsuranceState) {
                if let actionState = state.loadingStates[action] {
                    switch actionState {
                    case .loading:
                        withAnimation {
                            self.isLoading = true
                            self.presentError = false
                        }
                    case let .error(error):
                        if let onError {
                            onError()
                        }else {
                            withAnimation {
                                self.isLoading = false
                                self.error = error
                                self.presentError = true
                            }
                        }
                    }
                } else {
                    withAnimation {
                        self.isLoading = false
                        self.presentError = false
                    }
                }
            }
            let store: TravelInsuranceStore = globalPresentableStoreContainer.get()
            disposeBag += store.stateSignal.onValue { state in
                handle(state: state)
            }
            handle(state: store.state)

        }
    }
}
