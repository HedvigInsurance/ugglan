import Foundation
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import UIKit

@MainActor
public protocol TrackingViewNameProtocol {
    var nameForTracking: String { get }
}

@MainActor
extension String: TrackingViewNameProtocol {
    public var nameForTracking: String {
        self
    }
}

@MainActor
public class Router: ObservableObject {
    var routes = [AnyHashable]()
    var routesToBePushedAfterViewAppears = [any Hashable & TrackingViewNameProtocol]()
    fileprivate var onPush:
        ((_ options: RouterDestionationOptions, _ view: AnyView, _ contentName: String) -> UIViewController?)?
    fileprivate var onPop: (() -> Void)?
    fileprivate var onPopToRoot: (() -> Void)?
    fileprivate var onPopVC: ((UIViewController) -> Void)?
    fileprivate var onPopAtIndex: ((Int) -> Void)?
    fileprivate var onDismiss: ((_ withDismissingAll: Bool) -> Void)?

    public init() {}

    var builders: [String: Builderrr<AnyView>] = [:]
    public func push<T>(_ route: T) where T: Hashable & TrackingViewNameProtocol {
        let key = "\(T.self)"
        if let builder = builders[key], let view = builder.builder(route) {
            _ = onPush?(builder.options, view, route.nameForTracking)
            routes.append(key)
        } else {
            routesToBePushedAfterViewAppears.append(route)
        }
    }

    func push<T>(view: T) -> UIViewController? where T: View {
        routes.append("\(type(of: view))")
        return onPush?([], AnyView(view), "\(T.self)")
    }

    public func pop<T>(_ hash: T.Type) {
        if let index = routes.lastIndex(of: "\(hash.self)") {
            routes.remove(at: index)
            onPopAtIndex?(index)
        }
    }

    public func pop<T>(_ view: T) where T: View {
        if let index = routes.firstIndex(of: "\(type(of: view))") {
            routes.remove(at: index)
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

    public func dismiss(withDismissingAll: Bool = false) {
        onDismiss?(withDismissingAll)
    }

    fileprivate func dismissPresentedVcFor(vc: UIViewController?) {
        if let presentedViewController = vc?.presentedViewController {
            dismissPresentedVcFor(vc: presentedViewController)
            presentedViewController.dismiss(animated: false)
        }
    }

    fileprivate func getTopPresentedVcFor(vc: UIViewController?) -> UIViewController? {
        if let presentedViewController = vc?.presentedViewController {
            return getTopPresentedVcFor(vc: presentedViewController)
        }
        return vc
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
    let tracking: TrackingViewNameProtocol
    @ViewBuilder var initialView: () -> Screen

    public init(
        router: Router,
        options: RouterOptions = [],
        tracking: TrackingViewNameProtocol,
        @ViewBuilder initial: @escaping () -> Screen
    ) {
        initialView = initial
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
        initialView = initial
        self.router = router
        self.tracking = tracking
        self.options = options
    }

    public func makeUIViewController(context _: Context) -> UINavigationController {
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
            vc.onViewWillLayoutSubviews = { [weak vc] in
                guard let vc = vc else { return }
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

            vc.onViewDidLayoutSubviews = { [weak vc] in
                guard let vc = vc else { return }
                if #available(iOS 16.0, *) {
                    vc.sheetPresentationController?
                        .animateChanges {
                            UIApplication.shared.getTopViewController()?.sheetPresentationController?
                                .invalidateDetents()
                        }
                } else {
                    vc.sheetPresentationController?
                        .animateChanges {}
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
        router.onPopVC = { _ in
            //            [weak navigation] vc in
            //            navigation?.popViewController(vc, options: [])
        }
        router.onPopAtIndex = { [weak navigation] index in
            if let viewControllers = navigation?.viewControllers {
                var newVCs = viewControllers
                newVCs.remove(at: index + 1)
                navigation?.setViewControllers(newVCs, animated: true)
            }
        }
        navigation.onDeinit = { [weak router] in
            Task { @MainActor in
                router?.builders.removeAll()
            }
        }

        router.onDismiss = { [weak navigation, weak router] withDismissingAll in
            /// If we have presentedView controllers,
            /// take the screenshot of top one and add it to navigation to avoid odd dismissing
            /// dismiss presented view controllers without animations
            if withDismissingAll {
                if navigation?.presentedViewController != nil,
                    let vc = router?.getTopPresentedVcFor(vc: navigation),
                    let viewToAdd = vc.view.snapshotView(afterScreenUpdates: false)
                {
                    navigation?.view.addSubview(viewToAdd)
                    router?.dismissPresentedVcFor(vc: navigation)
                }
            }
            navigation?.dismiss(animated: true)
        }

        Task { [weak router] in
            for item in router?.routesToBePushedAfterViewAppears ?? [] {
                router?.push(item)
            }
            router?.routesToBePushedAfterViewAppears = []
        }

        return navigation
    }

    public func updateUIViewController(_: UINavigationController, context _: Context) {}
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
        tracking: TrackingViewNameProtocol
    ) -> some View {
        modifier(EmbededInNavigation(options: options, tracking: tracking, router: router))
    }
}

private struct EmbededInNavigation: ViewModifier {
    @StateObject var router = Router()
    let options: RouterOptions
    let tracking: TrackingViewNameProtocol

    init(options: RouterOptions, tracking: TrackingViewNameProtocol, router: Router? = nil) {
        if let router {
            _router = StateObject(wrappedValue: router)
        }
        self.options = options
        self.tracking = tracking
    }

    func body(content: Content) -> some View {
        RouterHost(router: router, options: options, tracking: tracking) {
            content
                .environmentObject(router)
        }
        .ignoresSafeArea()
    }
}

extension View {
    @MainActor public func configureTitle(_ title: String) -> some View {
        introspect(.viewController, on: .iOS(.v13...)) { vc in
            UIView.performWithoutAnimation { [weak vc] in
                vc?.title = title
            }
        }
    }

    @ViewBuilder
    @MainActor public func configureTitleView(
        title: String,
        subTitle: String? = nil,
        titleColor: TitleColor? = nil,
        onTitleTap: (() -> Void)? = nil
    ) -> some View {
        if #available(iOS 26.0, *) {
            self.toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    titleView(title: title, subTitle: subTitle, titleColor: titleColor ?? .default)
                        .fixedSize()
                        .onTapGesture {
                            onTitleTap?()
                        }
                }
                .sharedBackgroundVisibility(.hidden)
            }
        } else {
            introspect(.viewController, on: .iOS(.v13...)) { vc in
                vc.navigationItem.titleView = getTitleUIView(
                    title: title,
                    subTitle: subTitle,
                    titleColor: titleColor ?? .default,
                    onTitleTap: onTitleTap
                )
            }
        }
    }

    @MainActor public var enableModalInPresentation: some View {
        introspect(.viewController, on: .iOS(.v13...)) { vc in
            vc.isModalInPresentation = true
        }
    }

    public func getTitleUIView(
        title: String,
        subTitle: String?,
        titleColor: TitleColor,
        onTitleTap: (() -> Void)? = nil
    ) -> UIView {
        let view: UIView = UIHostingController(
            rootView: titleView(title: title, subTitle: subTitle, titleColor: titleColor)
                .onTapGesture {
                    onTitleTap?()
                }
        )
        .view
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        return view
    }

    @ViewBuilder
    private func titleView(title: String, subTitle: String?, titleColor: TitleColor) -> some View {
        Group {
            if let subTitle {
                VStack(alignment: .leading, spacing: 0) {
                    hText(title, style: .heading1)
                        .foregroundColor(titleViewColor(titleColor))
                        .accessibilityAddTraits(.isHeader)
                    hText(subTitle, style: .heading1)
                        .foregroundColor(hTextColor.Opaque.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                hText(title, style: .heading1)
                    .foregroundColor(titleViewColor(titleColor))
            }
        }
        .padding(.top, .padding8)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }

    @hColorBuilder
    private func titleViewColor(_ titleColor: TitleColor) -> some hColor {
        if titleColor == .red {
            hSignalColor.Red.element
        } else {
            hTextColor.Opaque.primary
        }
    }
}

public enum TitleColor: Sendable {
    case `default`
    case red
}

@MainActor
public protocol TitleView {
    func getTitleView() -> UIView
}
