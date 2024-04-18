import Foundation
import SwiftUI
import UIKit

public struct RouterOptions: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

public class Router: ObservableObject {
    private var routes = [AnyHashable]()
    fileprivate var onPush: ((AnyView) -> UIViewController?)?
    fileprivate var onPop: (() -> Void)?
    fileprivate var onPopToRoot: (() -> Void)?
    fileprivate var onPopVC: ((UIViewController) -> Void)?
    fileprivate var onPopAtIndex: ((Int) -> Void)?

    public init() {}

    var builders: [String: (AnyHashable) -> AnyView?] = [:]

    public func push<T>(_ route: T) where T: Hashable {
        routes.append(route)
        if let builder = builders["\(T.self)"], let view = builder(route) {
            _ = onPush?(view)
        }
    }

    func push<T>(view: T) -> UIViewController? where T: View {
        routes.append("\(type(of: view))")
        return onPush?(AnyView(view))
    }

    func pop(vc: UIViewController) {
        onPopVC?(vc)
    }

    public func pop<T>(_ hash: T) where T: Hashable {
        if let index = routes.firstIndex(of: hash) {
            onPopAtIndex?(index)
        }
    }
    public func pop<T>(_ view: T) where T: View {
        if let index = routes.firstIndex(of: "\(type(of: view))") {
            onPopAtIndex?(index)
        }
    }

    public func pop() {
        routes.removeLast()
        onPop?()
    }

    public func popToRoot() {
        routes.removeAll()
        onPopToRoot?()
    }
}
public struct RouterHost<Screen: View>: UIViewControllerRepresentable {

    let router: Router
    let options: RouterOptions

    var initialView: Screen

    public init(
        router: Router,
        options: RouterOptions = [],
        @ViewBuilder initial: @escaping () -> Screen
    ) {
        self.initialView = initial()
        self.router = router
        self.options = options
    }

    public func makeUIViewController(context: Context) -> UINavigationController {
        let navigation: hNavigationBaseController = {
            if options.contains(.largeNavigationBar) {
                return hNavigationControllerWithLargerNavBar()
            } else if options.contains(.navigationBarWithProgress) {
                return hNavigationController(additionalHeight: 4)
            }
            return hNavigationController()
        }()
        navigation.setViewControllers(
            [hHostingController(rootView: initialView.environmentObject(router))],
            animated: false
        )
        router.onPush = { [weak router, weak navigation] view in guard let router = router else { return nil }
            let vc = hHostingController(rootView: view.environmentObject(router))
            navigation?
                .pushViewController(
                    vc,
                    animated: true
                )
            return vc
        }

        router.onPop = { [weak navigation] in
            navigation?.popViewController(animated: true)
        }

        router.onPopToRoot = { [weak navigation] in
            navigation?.popToRootViewController(animated: true)
        }
        router.onPopVC = { [weak navigation] vc in
            navigation?.popViewController(vc, options: [])
        }
        router.onPopAtIndex = { [weak navigation] index in
            if let viewControllers = navigation?.viewControllers {
                var newVCs = viewControllers
                newVCs.remove(at: index + 1)
                navigation?.setViewControllers(newVCs, animated: true)
            }
        }
        navigation.onDeinit = { [weak router] in
            router?.builders.removeAll()
        }
        return navigation
    }

    public func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
    public typealias UIViewControllerType = UINavigationController
}