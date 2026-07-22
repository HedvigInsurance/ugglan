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

    /// Dismiss button that shows a confirmation alert only when `withAlert` is `true`,
    /// and dismisses directly otherwise. Use when the alert should depend on runtime state.
    /// `title`, `confirmButtonTitle`, and `cancelButtonTitle` fall back to the generic
    /// "Are you sure?" / "Yes" / "No" copy when not provided.
    public func withDismissButton(
        withAlert: Bool,
        title: String? = nil,
        message: String? = nil,
        confirmButtonTitle: String? = nil,
        cancelButtonTitle: String? = nil
    ) -> some View {
        modifier(
            DismissButton(
                withAlert: withAlert,
                title: title,
                message: message,
                confirmButtonTitle: confirmButtonTitle,
                cancelButtonTitle: cancelButtonTitle
            )
        )
    }
}

private struct DismissButton: ViewModifier {
    let reducedTopSpacing: Int
    let withAlert: Bool
    let title: String?
    let message: String?
    let confirmButtonTitle: String?
    let cancelButtonTitle: String?
    @EnvironmentObject var router: NavigationRouter
    @State var isAlertPresented = false

    init(
        withAlert: Bool = false,
        title: String? = nil,
        message: String? = nil,
        confirmButtonTitle: String? = nil,
        cancelButtonTitle: String? = nil,
        reducedTopSpacing: Int = 0,
    ) {
        self.reducedTopSpacing = reducedTopSpacing
        self.withAlert = withAlert
        self.title = title
        self.message = message
        self.confirmButtonTitle = confirmButtonTitle
        self.cancelButtonTitle = cancelButtonTitle
    }

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
                        if #available(iOS 26.0, *) {
                            hCoreUIAssets.close.view
                                .closeButtonOffset(y: CGFloat(reducedTopSpacing))
                        } else {
                            hCoreUIAssets.close.view
                                .closeButtonOffset(y: CGFloat(reducedTopSpacing))
                                .frame(minWidth: 44, minHeight: 44)
                        }
                    }
                    .foregroundColor(hTextColor.Opaque.primary)
                    .accessibilityLabel(L10n.a11YClose)
                    .accessibilityAddTraits(.isButton)
                    .configureAlert(
                        title: title,
                        message: message,
                        confirmButton: confirmButtonTitle,
                        cancelButton: cancelButtonTitle,
                        isPresented: $isAlertPresented
                    )
                    .foregroundColor(hTextColor.Opaque.primary)
                    .accessibilityLabel(L10n.a11YClose)
                    .accessibilityAddTraits(.isButton)
                }
            }
    }
}

extension View {
    func configureAlert(
        title: String? = nil,
        message: String? = nil,
        confirmButton: String? = nil,
        cancelButton: String? = nil,
        isPresented: Binding<Bool>
    ) -> some View {
        modifier(
            DismissAlertPopup(
                title: title ?? L10n.General.areYouSure,
                message: message,
                confirmButton: confirmButton ?? L10n.General.yes,
                cancelButton: cancelButton ?? L10n.General.no,
                isPresented: isPresented
            )
        )
    }
}

private struct DismissAlertPopup: ViewModifier {
    let title: String
    let message: String
    let confirmButton: String
    let cancelButton: String

    @Binding var isPresented: Bool
    @EnvironmentObject var router: NavigationRouter

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
                hText(message)
            }
    }
}

extension View {
    @ViewBuilder
    func closeButtonOffset(y: CGFloat) -> some View {
        if #available(iOS 26.0, *) {
            self
        } else {
            offset(y: y)
        }
    }
}
