import Foundation
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import hCore

extension View {
    public func withDismissButton() -> some View {
        modifier(
            DismissButton(withAlert: false)
        )
    }

    public func withAlertDismiss() -> some View {
        modifier(
            DismissButton(withAlert: true)
        )
    }
}

private struct DismissButton: ViewModifier {
    let withAlert: Bool
    @EnvironmentObject var router: Router
    @State var isAlertPresented = false
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(
                    placement: .topBarTrailing
                ) {
                    Button {
                        if withAlert {
                            isAlertPresented = true
                        } else {
                            router.dismiss()
                        }
                    } label: {
                        hCoreUIAssets.close.view
                            .resizable()
                            .frame(minWidth: 24, minHeight: 24)
                    }
                    .foregroundColor(hTextColor.Opaque.primary)
                    .accessibilityLabel(L10n.a11YClose)
                    .accessibilityAddTraits(.isButton)
                }
            }
            .withDismissAlert(isPresented: $isAlertPresented)
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
    @EnvironmentObject var router: Router

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
                        isPresented = false
                    }
                    Button(confirmButton, role: .destructive) {
                        router.dismiss()
                    }
                }
            } message: {
                hText(message ?? "")
            }
    }
}

extension View {
    public func withDismissButton(reducedTopSpacing: Int = 0) -> some View {
        modifier(CloseButtonModifier(reducedTopSpacing: reducedTopSpacing))
    }
}

private struct CloseButtonModifier: ViewModifier {
    let reducedTopSpacing: Int
    @EnvironmentObject var router: Router

    func body(content: Content) -> some View {
        content
            .setToolbarTrailing {
                Button {
                    router.dismiss()
                } label: {
                    hCoreUIAssets.close.view
                        .frame(minWidth: 24, minHeight: 44)
                        .foregroundColor(hFillColor.Opaque.primary)
                }
                .foregroundColor(hTextColor.Opaque.primary)
                .accessibilityLabel(L10n.a11YClose)
                .accessibilityAddTraits(.isButton)
            }
    }
}

extension View {
    @ViewBuilder
    func closeButtonOffset(y: CGFloat) -> some View {
        if isLiquidGlassEnabled {
            self
        } else {
            offset(y: y)
        }
    }
}
