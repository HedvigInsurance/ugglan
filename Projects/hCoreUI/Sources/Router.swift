import Foundation
import SwiftUI
import UIKit

public class Router: ObservableObject {
    private var routes = [AnyHashable]()
    fileprivate var onPush: ((RouterDestionationOptions, AnyView) -> UIViewController?)?
    fileprivate var onPop: (() -> Void)?
    fileprivate var onPopToRoot: (() -> Void)?
    fileprivate var onPopVC: ((UIViewController) -> Void)?
    fileprivate var onPopAtIndex: ((Int) -> Void)?

    public init() {}

    var builders: [String: (options: RouterDestionationOptions, builder: (AnyHashable) -> AnyView?)] = [:]

    public func push<T>(_ route: T) where T: Hashable {
        let key = "\(T.self)"
        if let builder = builders[key], let view = builder.builder(route) {
            _ = onPush?(builder.options, view)
            self.routes.append(key)
        }
    }

    func push<T>(view: T) -> UIViewController? where T: View {
        routes.append("\(type(of: view))")
        return onPush?([], AnyView(view))
    }

    //    func pop(vc: UIViewController) {
    //        onPopVC?(vc)
    //    }

    public func pop<T>(_ hash: T.Type) {
        if let index = routes.lastIndex(of: "\(hash.self)") {
            self.routes.remove(at: index)
            onPopAtIndex?(index)
        }
    }
    public func pop<T>(_ view: T) where T: View {
        if let index = routes.firstIndex(of: "\(type(of: view))") {
            self.routes.remove(at: index)
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

    deinit {
        let ss = ""
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
        router.onPush = { [weak router, weak navigation] options, view in guard let router = router else { return nil }
            let vc = hHostingController(rootView: view.environmentObject(router))
            vc.onViewWillLayoutSubviews = { [weak vc] in guard let vc = vc else { return }
                if options.contains(.hidesBackButton) {
                    vc.navigationItem.setHidesBackButton(true, animated: true)
                }
                //                if options.contains(.withDismiss) {
                //                    let item = UIBarButtonItem(image: HCoreUIAsset.close.image, style: .done, target: vc, action: #selector(vc.onCloseButton))
                //                    vc.navigationItem.rightBarButtonItem = item
                //                }
            }
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

public struct ViewRouterOptions: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}
