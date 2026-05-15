import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect

@MainActor
public enum VisibleScreenTracker {
    private struct Entry {
        let name: String
        weak var vc: UIViewController?
    }

    private static var entries: [Entry] = []

    public static func isVisible<V: View>(_ type: V.Type) -> Bool {
        isAnyVisible([type])
    }

    public static func isAnyVisible(_ types: [Any.Type]) -> Bool {
        entries.removeAll { $0.vc == nil }
        guard let topVC = leafVisibleVC() else { return false }
        let names = types.map { String(describing: $0) }
        for entry in entries.reversed() {
            guard let vc = entry.vc else { continue }
            if vc === topVC || vc.isAncestor(of: topVC) {
                return names.contains(entry.name)
            }
        }
        return false
    }

    fileprivate static func register(name: String, vc: UIViewController) {
        entries.removeAll { $0.vc == nil || $0.vc === vc }
        entries.append(Entry(name: name, vc: vc))
    }

    private static func leafVisibleVC() -> UIViewController? {
        var current = UIApplication.shared.getRootViewController()
        while let presented = current?.presentedViewController {
            current = presented
        }
        while let vc = current {
            if let tab = (vc as? UITabBarController)
                ?? vc.children.first(where: { $0 is UITabBarController }) as? UITabBarController,
                let selected = tab.selectedViewController
            {
                current = selected
            } else if let nav = (vc as? UINavigationController)
                ?? vc.children.first(where: { $0 is UINavigationController }) as? UINavigationController,
                let top = nav.topViewController
            {
                current = top
            } else {
                return vc
            }
        }
        return nil
    }
}

extension UIViewController {
    fileprivate func isAncestor(of vc: UIViewController) -> Bool {
        var current: UIViewController? = vc.parent
        while let c = current {
            if c === self { return true }
            current = c.parent
        }
        return false
    }
}

extension View {
    public func trackVisibility<V: View>(as type: V.Type) -> some View {
        let name = String(describing: type)
        return introspect(.viewController, on: .iOS(.v13...)) { vc in
            VisibleScreenTracker.register(name: name, vc: vc)
        }
    }
}
