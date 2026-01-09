import Foundation
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import hCore

extension View {
    public func withDismissButton() -> some View {
        modifier(
            DismissButton()
        )
    }

    public func withDismissButton(reducedTopSpacing: Int = 0) -> some View {
        modifier(DismissButton(reducedTopSpacing: reducedTopSpacing))
    }

    public func withAlertDismiss(message: String? = nil) -> some View {
        modifier(
            DismissButton(withAlert: true, message: message)
        )
    }
}

private struct DismissButton: ViewModifier {
    let reducedTopSpacing: Int
    let withAlert: Bool
    let message: String?
    @EnvironmentObject var router: Router
    @State var isAlertPresented = false

    init(
        withAlert: Bool = false,
        message: String? = nil,
        reducedTopSpacing: Int = 0,
    ) {
        self.reducedTopSpacing = reducedTopSpacing
        self.withAlert = withAlert
        self.message = message
    }

    func body(content: Content) -> some View {
        content
            .setToolbarTrailing {
                Button {
                    if withAlert {
                        isAlertPresented = true
                    } else {
                        router.dismiss()
                    }
                } label: {
                    Group {
                        hCoreUIAssets.close.view
                            .closeButtonOffset(y: CGFloat(reducedTopSpacing))
                    }
                    .frame(minWidth: 44, minHeight: 44)
                }
                .foregroundColor(hTextColor.Opaque.primary)
                .accessibilityLabel(L10n.a11YClose)
                .accessibilityAddTraits(.isButton)
            }
            .configureAlert(message: message, isPresented: $isAlertPresented)
    }
}

extension View {
    func configureAlert(message: String? = nil, isPresented: Binding<Bool>) -> some View {
        modifier(DismissAlertPopup(message: message, isPresented: isPresented))
    }
}

private struct DismissAlertPopup: ViewModifier {
    let title: String
    let message: String
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
        self.message = message ?? L10n.General.progressWillBeLostAlert
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
    @ViewBuilder
    func closeButtonOffset(y: CGFloat) -> some View {
        if #available(iOS 26, *) {
            self
        } else {
            offset(y: y)
        }
    }
}
