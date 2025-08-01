import Combine
import Foundation
import SwiftUI

public struct PresentableStoreLens<S: Store, Value: Equatable, Content: View>: View {
    typealias Getter = (_ state: S.State) -> Value
    typealias Setter = (_ value: Value) -> S.Action?

    @Environment(\.presentableStoreLensAnimation) var animation
    @State var value: Value
    var getter: Getter
    var setter: Setter

    var store: S

    var content: (_ value: Value, _ setter: @escaping (_ newValue: Value) -> Void) -> Content

    public init(
        _: S.Type,
        getter: @escaping (_ state: S.State) -> Value,
        setter: @escaping (_ value: Value) -> S.Action?,
        @ViewBuilder _ content: @escaping (_ value: Value, _ setter: @escaping (_ newValue: Value) -> Void) -> Content
    ) {
        self.getter = getter
        self.setter = setter
        self.content = content

        let store: S = globalPresentableStoreContainer.get()
        self.store = store

        _value = State(initialValue: getter(store.state))
    }

    public init(
        _: S.Type,
        getter: @escaping (_ state: S.State) -> Value,
        @ViewBuilder _ content: @escaping (_ value: Value) -> Content
    ) {
        self.getter = getter
        setter = { _ in nil }
        self.content = { value, _ in content(value) }

        let store: S = globalPresentableStoreContainer.get()
        self.store = store

        _value = State(initialValue: getter(store.state))
    }

    public var body: some View {
        content(
            value,
            { newValue in
                if let action = setter(newValue) {
                    store.send(action)
                }
            }
        )
        .onReceive(
            store.stateSignal
                .removeDuplicates(by: { lhs, rhs in
                    getter(lhs) == getter(rhs)
                })
        ) { _ in
            if let animation = animation {
                withAnimation(animation) {
                    value = getter(store.state)
                }
            } else {
                value = getter(store.state)
            }
        }
    }
}

public struct PresentableLoadingStoreLens<
    S: Store & StoreLoading,
    LoadingContent: View,
    ErrorContent: View,
    FinishedContent: View
>: View {
    @Environment(\.presentableStoreLensAnimation) var animation
    @State var state: LoadingState<String>?
    var loadingState: S.Loading

    var store: S
    var loadingContent: () -> LoadingContent
    var errorContent: (_ error: String) -> ErrorContent
    var finishedContent: () -> FinishedContent

    public init(
        _: S.Type,
        loadingState: S.Loading,
        @ViewBuilder loading loadingContent: @escaping () -> LoadingContent,
        @ViewBuilder error errorContent: @escaping (_ error: String) -> ErrorContent,
        @ViewBuilder success finishedContent: @escaping () -> FinishedContent
    ) {
        self.loadingContent = loadingContent
        self.errorContent = errorContent
        self.finishedContent = finishedContent
        let store: S = globalPresentableStoreContainer.get()
        self.store = store
        self.loadingState = loadingState
        let value = store.loadingState.first(where: { $0.key == loadingState })?.value
        _state = State(initialValue: value)
    }

    public var body: some View {
        Group {
            switch state {
            case .loading:
                loadingContent()
            case let .error(error):
                errorContent(error)
            case nil:
                finishedContent()
            }
        }
        .onReceive(
            store.loadingSignal
        ) { value in
            let currentValue = value.first(where: { $0.key == loadingState })?.value
            if let animation {
                withAnimation(animation) {
                    state = currentValue
                }
            } else {
                state = currentValue
            }
        }
    }
}

private struct EnvironmentPresentableStoreLensAnimation: EnvironmentKey {
    static let defaultValue: Animation? = nil
}

extension EnvironmentValues {
    public var presentableStoreLensAnimation: Animation? {
        get { self[EnvironmentPresentableStoreLensAnimation.self] }
        set { self[EnvironmentPresentableStoreLensAnimation.self] = newValue }
    }
}

extension View {
    public func presentableStoreLensAnimation(_ animation: Animation?) -> some View {
        environment(\.presentableStoreLensAnimation, animation)
    }
}
