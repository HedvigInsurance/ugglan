import Foundation
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import hCore

extension View {
    public func withDismissButton(
        title: String,
        message: String?,
        confirmButton: String,
        cancelButton: String
    ) -> some View {
        modifier(
            DismissButton()
        )
    }
}

private struct DismissButton: ViewModifier {
    @State var isPresented = false
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(
                    placement: .topBarTrailing
                ) {
                    Button {
                        isPresented = true
                    } label: {
                        hCoreUIAssets.close.view
                            .frame(minWidth: 44, minHeight: 44)
                    }
                    .foregroundColor(hTextColor.Opaque.primary)
                    .accessibilityLabel(L10n.a11YClose)
                    .accessibilityAddTraits(.isButton)
                }
            }
            .withDismissAlert(isPresented: $isPresented)
    }
}

extension View {
    public func withDismissAlert(isPresented: Binding<Bool>) -> some View {
        modifier(DismissAlertPopup(isPresented: isPresented))
    }
}

private struct DismissAlertPopup: ViewModifier {
    let title: String
    let message: String?
    let confirmButton: String
    let cancelButton: String

    @Binding var isPresented: Bool
    @StateObject var vm = DismissButtonViewModel()

    init(
        title: String = L10n.General.areYouSure,
        message: String? = L10n.General.progressWillBeLostAlert,
        confirmButton: String = L10n.General.yes,
        cancelButton: String = L10n.General.no,
        isPresented: Binding<Bool>
    ) {
        self.title = title
        self.message = message
        self.confirmButton = confirmButton
        self.cancelButton = cancelButton
        self._isPresented = isPresented
    }
    func body(content: Content) -> some View {
        content
            .alert(title, isPresented: $isPresented) {
                HStack {
                    Button(cancelButton, role: .cancel) {
                        dismiss()
                    }
                    Button(confirmButton, role: .destructive) { [weak vm] in
                        vm?.vc?.dismiss(animated: true)
                    }
                }
            } message: {
                hText(message ?? "")
            }
            .introspect(.viewController, on: .iOS(.v13...)) { [weak vm] vc in
                vm?.vc = vc
            }
    }

    private func dismiss() {
        isPresented = false
    }
}

private class DismissButtonViewModel: ObservableObject {
    weak var vc: UIViewController?
}

extension View {
    public func withDismissButton(reducedTopSpacing: Int = 0) -> some View {
        modifier(CloseButtonModifier(reducedTopSpacing: reducedTopSpacing))
    }

    public func withAlertDismiss() -> some View {
        withDismissButton(
            title: L10n.General.areYouSure,
            message: L10n.General.progressWillBeLostAlert,
            confirmButton: L10n.General.yes,
            cancelButton: L10n.General.no
        )
    }
}

private struct CloseButtonModifier: ViewModifier {
    @StateObject var vm = DismissButtonViewModel()
    let reducedTopSpacing: Int

    func body(content: Content) -> some View {
        content
            .setToolbarTrailing {
                Button {
                    vm.vc?.dismiss(animated: true)
                } label: {
                    hCoreUIAssets.close.view
                        .closeButtonOffset(y: CGFloat(-reducedTopSpacing))
                        .foregroundColor(hFillColor.Opaque.primary)
                        .frame(minWidth: 44, minHeight: 44)
                }
                .foregroundColor(hTextColor.Opaque.primary)
                .accessibilityLabel(L10n.a11YClose)
                .accessibilityAddTraits(.isButton)
            }
            .introspect(.viewController, on: .iOS(.v13...)) { vc in
                vm.vc = vc
            }
    }
}

extension View {
    @ViewBuilder
    func closeButtonOffset(y: CGFloat) -> some View {
        if #available(iOS 26, *) {
            self
        } else {
            offset(y: y)
        }
    }
}
