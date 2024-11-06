import SwiftUI

extension View {
    public func onDeinit(_ execute: @escaping () -> Void) -> some View {
        modifier(OnDeinit(execute: execute))
    }
}

private struct OnDeinit: ViewModifier {
    @StateObject var vm = OnDeinitViewModel()
    let execute: () -> Void
    func body(content: Content) -> some View {
        content.onAppear { [weak vm] in
            vm?.execute = execute
        }
    }
}

private class OnDeinitViewModel: ObservableObject {
    var execute: (() -> Void)?

    deinit {
        execute?()
    }
}
