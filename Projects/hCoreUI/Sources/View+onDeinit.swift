import SwiftUI
import hCore

extension View {
    public func onDeinit(_ execute: @escaping () -> Void) -> some View {
        modifier(OnDeinit(execute: execute))
    }

    /// Releases the iOS 26 keyboard retention on teardown. Attach to screens that host a text
    /// input inside a sheet. See `UIApplication.releaseKeyboardRetainedViews()`.
    public func releasesKeyboardRetentionOnDeinit() -> some View {
        onDeinit {
            UIApplication.releaseKeyboardRetainedViews()
        }
    }
}

private struct OnDeinit: ViewModifier {
    @State var vm = OnDeinitViewModel()
    let execute: () -> Void
    func body(content: Content) -> some View {
        content.onAppear { [weak vm] in
            vm?.execute = execute
        }
    }
}

@Observable
private class OnDeinitViewModel {
    @ObservationIgnored var execute: (() -> Void)?

    deinit {
        execute?()
    }
}
