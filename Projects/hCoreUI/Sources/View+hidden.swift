import SwiftUI

extension View {
    public func hidden(_ hide: Binding<Bool>) -> some View {
        modifier(HideViewController(hide: hide))
    }
}

struct HideViewController: ViewModifier {
    @Binding var hide: Bool
    @State private var vc: UIViewController?

    init(hide: Binding<Bool>) {
        _hide = hide
    }

    func body(content: Content) -> some View {
        content.introspectViewController { vc in
            DispatchQueue.main.async { [weak vc] in
                self.vc = vc
            }
        }
        .onChange(of: hide) { [weak vc] newValue in
            if let vc = vc {
                UIView.animate(withDuration: 0.4) {
                    let properVC = findProverVC(from: vc)
                    properVC?.view.alpha = hide ? 0 : 1
                }
            }
        }
    }

    private func findProverVC(from vc: UIViewController?) -> UIViewController? {
        if let vc {
            if let navigation = vc.navigationController {
                return findProverVC(from: navigation)
            } else {
                if vc.presentationController is BlurredSheetPresenationController {
                    return vc
                } else if let superviewVc = vc.view.superview?.viewController {
                    return findProverVC(from: superviewVc)
                }
            }
        }
        return nil
    }
}
