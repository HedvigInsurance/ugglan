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
            DismissButton(
                title: title,
                message: message,
                confirmButton: confirmButton,
                cancelButton: cancelButton
            )
        )
    }
}

private struct DismissButton: ViewModifier {
    let title: String
    let message: String?
    let confirmButton: String
    let cancelButton: String
    @State var isPresented = false
    @StateObject var vm = DismissButtonViewModel()
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(
                    placement: .topBarTrailing
                ) {
                    hCoreUIAssets.close.view
                        .onTapGesture {
                            isPresented = true
                        }
                }
            }
            .introspect(.viewController, on: .iOS(.v13...)) { vc in
                vm.vc = vc
            }
            .alert(isPresented: $isPresented) {
                Alert(
                    title: Text(title),
                    message: { if let message { return Text(message) } else { return nil } }(),
                    primaryButton: .default(Text(cancelButton)),
                    secondaryButton: .destructive(Text(confirmButton)) { [weak vm] in
                        vm?.vc?.dismiss(animated: true)
                    }
                )
            }
    }
}

private class DismissButtonViewModel: ObservableObject {
    weak var vc: UIViewController?
}

extension View {
    public func withDismissButton(reducedTopSpacing: Int = 0) -> some View {
        modifier(CloseButtonModifier(reducedTopSpacing: reducedTopSpacing))
    }
}

private struct CloseButtonModifier: ViewModifier {
    @StateObject var vm = DismissButtonViewModel()
    let reducedTopSpacing: Int

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(
                    placement: .topBarTrailing

                ) {
                    hCoreUIAssets.close.view
                        .onTapGesture {
                            vm.vc?.dismiss(animated: true)
                        }
                        .offset(y: CGFloat(-reducedTopSpacing))
                }
            }
            .introspect(.viewController, on: .iOS(.v13...)) { vc in
                vm.vc = vc
            }
    }
}
