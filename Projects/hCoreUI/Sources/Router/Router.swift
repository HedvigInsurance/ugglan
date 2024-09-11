import Foundation
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import UIKit

public protocol TrackingViewNameProtocol {
    var nameForTracking: String { get }
}

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

    public func push<T>(_ route: T) where T: Hashable & TrackingViewNameProtocol {
        let key = "\(T.self)"
        if let builder = builders[key], let view = builder.builder(route) {
            _ = onPush?(builder.options, view, route.nameForTracking)
            self.routes.append(key)
        }
    }

    func push<T>(view: T) -> UIViewController? where T: View {
        routes.append("\(type(of: view))")
        return onPush?([], AnyView(view), "\(T.self)")
    }

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
    let tracking: TrackingViewNameProtocol?
    @ViewBuilder var initialView: () -> Screen

    public init(
        router: Router,
        options: RouterOptions = [],
        tracking: TrackingViewNameProtocol? = nil,
        @ViewBuilder initial: @escaping () -> Screen
    ) {
        self.initialView = initial
        self.router = router
        self.options = options
        self.tracking = tracking
    }

    public var body: some View {
        RouterWrappedValue(router: router, options: options, tracking: tracking, initial: initialView)
            .ignoresSafeArea()
            .environmentObject(router)
    }
}

private struct RouterWrappedValue<Screen: View>: UIViewControllerRepresentable {

    let router: Router
    let options: RouterOptions
    let tracking: TrackingViewNameProtocol?
    var initialView: () -> Screen

    init(
        router: Router,
        options: RouterOptions = [],
        tracking: TrackingViewNameProtocol?,
        @ViewBuilder initial: @escaping () -> Screen
    ) {
        self.initialView = initial
        self.router = router
        self.tracking = tracking
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
        let controller = hHostingController(
            rootView: initialView().environmentObject(router),
            contentName: tracking?.nameForTracking ?? "\(Screen.self)"
        )
        navigation.setViewControllers(
            [controller],
            animated: false
        )
        if options.contains(.navigationBarHidden) {
            navigation.setNavigationBarHidden(true, animated: true)
        }
        router.onPush = { [weak router, weak navigation] options, view, name in
            guard let router = router else { return nil }
            let vc = hHostingController(rootView: view.environmentObject(router), contentName: name)
            vc.onViewWillLayoutSubviews = { [weak vc] in guard let vc = vc else { return }
                if options.contains(.hidesBackButton) {
                    vc.navigationItem.setHidesBackButton(true, animated: true)
                }
            }
            vc.onViewWillAppear = { [weak vc] in
                if options.contains(.hidesBottomBarWhenPushed) {
                    if let tabBarController = vc?.tabBarController {
                        tabBarController.tabBar.isHidden = true
                        UIView.transition(
                            with: tabBarController.tabBar,
                            duration: 0.35,
                            options: .transitionCrossDissolve,
                            animations: nil
                        )
                    }
                }
            }

            vc.onViewWillDisappear = { [weak vc] in
                if options.contains(.hidesBottomBarWhenPushed) {
                    if let tabBarController = vc?.tabBarController {
                        tabBarController.tabBar.isHidden = false
                        UIView.transition(
                            with: tabBarController.tabBar,
                            duration: 0.35,
                            options: .transitionCrossDissolve,
                            animations: nil
                        )
                    }
                }
            }

            vc.onViewDidLayoutSubviews = { [weak vc] in guard let vc = vc else { return }
                if #available(iOS 16.0, *) {
                    vc.sheetPresentationController?
                        .animateChanges {
                            UIApplication.shared.getTopViewController()?.sheetPresentationController?
                                .invalidateDetents()
                        }
                } else {
                    vc.sheetPresentationController?
                        .animateChanges {

                        }
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
    public func embededInNavigation(
        router: Router? = nil,
        options: RouterOptions = [],
        tracking: TrackingViewNameProtocol? = nil
    ) -> some View {
        return modifier(EmbededInNavigation(options: options, tracking: tracking, router: router))
    }
}

private struct EmbededInNavigation: ViewModifier {
    @StateObject var router = Router()
    let options: RouterOptions
    let tracking: TrackingViewNameProtocol?

    init(options: RouterOptions, tracking: TrackingViewNameProtocol?, router: Router? = nil) {
        if let router {
            self._router = StateObject(wrappedValue: router)
        }
        self.options = options
        self.tracking = tracking
    }
    func body(content: Content) -> some View {
        return RouterHost(router: router, options: options, tracking: tracking) {
            content
                .environmentObject(router)
        }
        .ignoresSafeArea()
    }
}

extension View {
    @MainActor public func configureTitle(_ title: String) -> some View {
        self.introspect(.viewController, on: .iOS(.v13...)) { vc in
            UIView.performWithoutAnimation { [weak vc] in
                vc?.title = title
            }
        }
    }

    @MainActor public func configureTitleView(_ titleView: some TitleView) -> some View {
        self.introspect(.viewController, on: .iOS(.v13...)) { vc in
            vc.navigationItem.titleView = titleView.getTitleView()
        }
    }

    @MainActor public var enableModalInPresentation: some View {
        self.introspect(.viewController, on: .iOS(.v13...)) { vc in
            vc.isModalInPresentation = true
        }
    }
}

public protocol TitleView {
    func getTitleView() -> UIView
}
