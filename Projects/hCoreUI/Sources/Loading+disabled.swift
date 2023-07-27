import Flow
import Foundation
import Presentation
import SwiftUI
import hCore

struct DisableInputModifier<StoreType: StoreLoading & Store>: ViewModifier {
    @PresentableStore var store: StoreType
    private let actions: [StoreType.Loading]
    @State var disabled = false

    init(
        _ type: StoreType.Type,
        actions: [StoreType.Loading]
    ) {
        self.actions = actions
    }
    func body(content: Content) -> some View {
        content
            .onReceive(
                store.loadingSignal
                    .plain()
                    .publisher
            ) { value in
                handleDisabled(value)
            }
            .onAppear {
                handleDisabled(store.loadingSignal.value)
            }
            .disabled(disabled)
    }

    private func handleDisabled(_ value: [StoreType.Loading: LoadingState<String>]) {
        let actions = value.filter({ self.actions.contains($0.key) })
        let hasLoadingActions = actions.filter({ $0.value == .loading }).count > 0
        withAnimation {
            disabled = hasLoadingActions
        }
    }
}

extension View {
    public func disableOn<StoreType: StoreLoading & Store>(
        _ store: StoreType.Type,
        _ actions: [StoreType.Loading]
    ) -> some View {
        self.modifier(DisableInputModifier(store, actions: actions))
    }
}
