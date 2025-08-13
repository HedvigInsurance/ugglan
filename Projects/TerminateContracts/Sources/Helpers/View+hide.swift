import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect

private struct HideVC: ViewModifier {
    @Binding var isHidden: Bool
    func body(content: Content) -> some View {
        content
            .onChange(of: isHidden) { _ in }
            .introspect(.viewController, on: .iOS(.v13...)) { vc in
                vc.view.alpha = isHidden ? 0 : 1
                vc.navigationController?.view.alpha = isHidden ? 0 : 1
            }
    }
}

extension View {
    func hide(_ hidden: Binding<Bool>) -> some View {
        modifier(HideVC(isHidden: hidden))
    }
}
