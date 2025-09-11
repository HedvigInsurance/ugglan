import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect

extension View {
    public var setViewController: some View {
        modifier(ViewControllerModifer())
    }
}

struct ViewControllerModifer: ViewModifier {
    @StateObject private var viewControllerModel = ViewControllerModel()

    func body(content: Content) -> some View {
        content
            .introspect(.viewController, on: .iOS(.v13...)) { [weak viewControllerModel] vc in
                viewControllerModel?.vc = vc
            }
            .environmentObject(viewControllerModel)
    }
}

public class ViewControllerModel: ObservableObject {
    public fileprivate(set) weak var vc: UIViewController?
}
