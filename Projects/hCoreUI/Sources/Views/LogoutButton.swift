import SwiftUI
import hCore

/// Logs out after the member confirms. Keep it a View of its own: its hButton/alert closures then only capture this
/// view, not an enclosing view holding a store (a store held via @AppObservedObject, which wraps @StateObject, would
/// otherwise stay pinned across logout).
public struct LogoutButton: View {
    @State private var showAlert = false

    public init() {}

    public var body: some View {
        hButton(
            .large,
            .ghost,
            content: .init(title: L10n.logoutButton),
            { showAlert = true }
        )
        .hUseButtonTextColor(.red)
        .foregroundColor(hSignalColor.Red.element)
        .alert(L10n.logoutAlertTitle, isPresented: $showAlert) {
            Button(L10n.logoutAlertActionCancel, role: .cancel) {}
            Button(L10n.logoutAlertActionConfirm, role: .destructive) {
                ApplicationState.preserveState(.notLoggedIn)
                ApplicationState.state = .notLoggedIn
            }
        }
    }
}
