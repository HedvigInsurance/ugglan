import Foundation
import SwiftUI
import UIKit

public class Router: ObservableObject {
    private var routes = [AnyHashable]()
    fileprivate var onPush:
        ((_ options: RouterDestionationOptions, _ view: AnyView, _ contentName: String) -> UIViewController?)?
    fileprivate var onPop: (() -> Void)?
    fileprivate var onPopToRoot: (() -> Void)?
    fileprivate var onPopVC: ((UIViewController) -> Void)?
    fileprivate var onPopAtIndex: ((Int) -> Void)?
    fileprivate var onDismiss: (() -> Void)?

    public init() {}

    var builders: [String: Builderrr<AnyView>] = [:]
    public func push<T>(_ route: T) where T: Hashable {
        let key = "\(T.self)"
        if let builder = builders[key], let view = builder.builder(route) {
            _ = onPush?(builder.options, view, builder.contentName)
            self.routes.append(key)
        }
    }

    func push<T>(view: T) -> UIViewController? where T: View {
        routes.append("\(type(of: view))")
        return onPush?([], AnyView(view), "\(T.self)")
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

    public func dismiss() {
        onDismiss?()
    }
}

struct Builderrr<Content: View> {
    let builder: (AnyHashable) -> Content?
    let contentName: String
    let options: RouterDestionationOptions
    init(builder: @escaping (AnyHashable) -> Content?, contentName: String, options: RouterDestionationOptions) {
        self.builder = builder
        self.contentName = contentName
        self.options = options
    }
}
public struct RouterHost<Screen: View>: View {
    let router: Router
    let options: RouterOptions
    @ViewBuilder var initialView: () -> Screen

    public init(
        router: Router,
        options: RouterOptions = [],
        @ViewBuilder initial: @escaping () -> Screen
    ) {
        self.initialView = initial
        self.router = router
        self.options = options
    }

    public var body: some View {
        RouterWrappedValue(router: router, options: options, initial: initialView)
            .ignoresSafeArea()
            .environmentObject(router)
    }
}

private struct RouterWrappedValue<Screen: View>: UIViewControllerRepresentable {

    let router: Router
    let options: RouterOptions

    var initialView: Screen

    init(
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
            [hHostingController(rootView: initialView.environmentObject(router), contentName: "\(Screen.self)")],
            animated: false
        )
        router.onPush = { [weak router, weak navigation] options, view, name in
            guard let router = router else { return nil }
            let vc = hHostingController(rootView: view.environmentObject(router), contentName: name)
            vc.onViewWillLayoutSubviews = { [weak vc] in guard let vc = vc else { return }
                if options.contains(.hidesBackButton) {
                    vc.navigationItem.setHidesBackButton(true, animated: true)
                }
            }
            navigation?
                .pushViewController(
                    vc,
                    animated: true
                )
            if options.contains(.hidesBackButton) {
                vc.navigationItem.setHidesBackButton(true, animated: true)
            }
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

        router.onDismiss = { [weak navigation] in
            navigation?.dismiss(animated: true)
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

extension View {
    public func embededInNavigation(options: RouterOptions = []) -> some View {
        modifier(EmbededInNavigation(options: options))
    }
}

private struct EmbededInNavigation: ViewModifier {
    @StateObject var router = Router()
    let options: RouterOptions
    func body(content: Content) -> some View {
        return RouterHost(router: router, options: options) {
            content
                .environmentObject(router)
        }
        .ignoresSafeArea()
    }
}

extension View {
    public func configureTitle(_ title: String) -> some View {
        self.introspectViewController { vc in
            vc.title = title
        }
    }
}
