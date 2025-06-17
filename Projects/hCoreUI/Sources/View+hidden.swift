import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect

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
        content
            .introspect(.viewController, on: .iOS(.v13...)) { vc in
                DispatchQueue.main.async { [weak vc] in
                    self.vc = vc
                }
            }
            .onChange(of: hide) { [weak vc] newValue in
                if let vc = vc {
                    UIView.animate(withDuration: 0.4) {
                        let properVC: UIViewController? = {
                            if #available(iOS 16.0, *) {
                                return self.findProperVC(from: vc)
                            } else {
                                return vc.navigationController?.view.superview?.viewController ?? vc
                            }
                        }()
                        properVC?.view.alpha = hide ? 0 : 1
                    }
                }
            }
    }

    private func findProperVC(from vc: UIViewController?) -> UIViewController? {
        if let vc {
            if let navigation = vc.navigationController {
                return findProperVC(from: navigation)
            } else {
                if vc.presentationController is BlurredSheetPresentationController {
                    return vc
                } else if let superviewVc = vc.view.superview?.viewController {
                    return findProperVC(from: superviewVc)
                } else if let parent = vc.parent {
                    return findProperVC(from: parent)
                }

            }
        }
        return nil
    }
}
