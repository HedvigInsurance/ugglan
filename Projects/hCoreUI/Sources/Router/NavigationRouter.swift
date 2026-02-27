import Foundation
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import UIKit
import hCore

@MainActor
public protocol TrackingViewNameProtocol {
    var nameForTracking: String { get }
}

@MainActor
public protocol NavigationTitleProtocol {
    var navigationTitle: String? { get }
}

@MainActor
extension String: TrackingViewNameProtocol {
    public var nameForTracking: String {
        self
    }
}

@MainActor
public class NavigationRouter: ObservableObject {
    @Published public var path = NavigationPath()
    var onDismiss: ((_ withDismissingAll: Bool) -> Void)?

    public init() {}

    public func push<T>(_ route: T) where T: Hashable & TrackingViewNameProtocol {
        path.append(route)
    }

    public func pop<T>(_ hash: T.Type) {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    public func pop<T>(_ view: T) where T: View {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    public func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    public func popToRoot() {
        path = NavigationPath()
    }

    public func dismiss(withDismissingAll: Bool = false) {
        onDismiss?(withDismissingAll)
    }

    func dismissPresentedVcFor(vc: UIViewController?) {
        if let presentedViewController = vc?.presentedViewController {
            dismissPresentedVcFor(vc: presentedViewController)
            presentedViewController.dismiss(animated: false)
        }
    }

    func getTopPresentedVcFor(vc: UIViewController?) -> UIViewController? {
        if let presentedViewController = vc?.presentedViewController {
            return getTopPresentedVcFor(vc: presentedViewController)
        }
        return vc
    }
}

// MARK: - NavigationStack-based host

public struct hNavigationStack<Screen: View>: View {
    @ObservedObject var router: NavigationRouter
    let options: RouterOptions
    let tracking: TrackingViewNameProtocol
    @ViewBuilder var initialView: () -> Screen

    public init(
        router: NavigationRouter,
        options: RouterOptions = [],
        tracking: TrackingViewNameProtocol,
        @ViewBuilder initial: @escaping () -> Screen
    ) {
        self.router = router
        self.options = options
        self.tracking = tracking
        self.initialView = initial
    }

    public var body: some View {
        NavigationStack(path: $router.path) {
            initialView()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(
                    options.contains(.navigationBarHidden) ? .hidden : .visible,
                    for: .navigationBar
                )
                .trackNavigation(name: tracking.nameForTracking)
        }
        .introspect(.navigationStack, on: .iOS(.v16...)) { navController in
            hNavigationStack.applyCustomStyling(to: navController, options: options)
            hNavigationStack.wireUpDismiss(navController: navController, router: router)
        }
        .environmentObject(router)
    }

    private static func applyCustomStyling(to navController: UINavigationController, options: RouterOptions) {
        if options.contains(.navigationBarHidden) {
            navController.setNavigationBarHidden(true, animated: false)
        }

        if options.contains(.largeNavigationBar) {
            object_setClass(navController.navigationBar, LargeNavBar.self)
            if options.contains(.extendedNavigationWidth) {
                (navController.navigationBar as? LargeNavBar)?.extendedNavigationWidth = true
            }
            navController.additionalSafeAreaInsets.top =
                hNavigationControllerWithLargerNavBar.navigationBarHeight - 44
        } else {
            object_setClass(navController.navigationBar, NavBar.self)
            if options.contains(.extendedNavigationWidth) {
                (navController.navigationBar as? NavBar)?.extendedNavigationWidth = true
            }
            if options.contains(.navigationBarWithProgress) {
                (navController.navigationBar as? NavBar)?.additionalHeight = 4
                navController.additionalSafeAreaInsets.top = 4
            }
        }
        navController.navigationBar.setNeedsLayout()
    }

    private static func wireUpDismiss(navController: UINavigationController, router: NavigationRouter) {
        router.onDismiss = { [weak navController, weak router] withDismissingAll in
            if withDismissingAll {
                if navController?.presentedViewController != nil,
                    let vc = router?.getTopPresentedVcFor(vc: navController),
                    let viewToAdd = vc.view.snapshotView(afterScreenUpdates: false)
                {
                    navController?.view.addSubview(viewToAdd)
                    router?.dismissPresentedVcFor(vc: navController)
                }
            }
            navController?.dismiss(animated: true)
        }
    }
}

// MARK: - NavigationStack destination modifiers

struct NavigationStackDestinationOptionsModifier: ViewModifier {
    let options: RouterDestionationOptions
    let trackingName: String?
    let navigationTitle: String?

    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(options.contains(.hidesBackButton))
            .toolbar(
                options.contains(.hidesBottomBarWhenPushed) ? .hidden : .automatic,
                for: .tabBar
            )
            .ifLet(navigationTitle) { view, title in
                view.navigationTitle(title)
            }
            .trackNavigation(name: trackingName)
    }
}

private struct NavigationTrackingModifier: ViewModifier {
    let name: String?
    private let key = UUID().uuidString

    func body(content: Content) -> some View {
        content
            .onAppear {
                if let name = name?.getTrackingViewName() {
                    logStartView(key, name)
                }
            }
            .onDisappear {
                if name?.getTrackingViewName() != nil {
                    logStopView(key)
                }
            }
    }
}

extension String {
    fileprivate func getTrackingViewName() -> String? {
        if lowercased().contains("anyview") || isEmpty || contains("Navigation") {
            return nil
        }
        return self
    }
}

extension View {
    func trackNavigation(name: String?) -> some View {
        modifier(NavigationTrackingModifier(name: name))
    }

    @ViewBuilder
    func ifLet<T, Content: View>(_ value: T?, @ViewBuilder transform: (Self, T) -> Content) -> some View {
        if let value {
            transform(self, value)
        } else {
            self
        }
    }
}

extension View {
    public func embededInNavigation(
        router: NavigationRouter? = nil,
        options: RouterOptions = [],
        tracking: TrackingViewNameProtocol
    ) -> some View {
        modifier(EmbededInNavigation(options: options, tracking: tracking, router: router))
    }
}

private struct EmbededInNavigation: ViewModifier {
    @StateObject var router = NavigationRouter()
    let options: RouterOptions
    let tracking: TrackingViewNameProtocol

    init(options: RouterOptions, tracking: TrackingViewNameProtocol, router: NavigationRouter? = nil) {
        if let router {
            _router = StateObject(wrappedValue: router)
        }
        self.options = options
        self.tracking = tracking
    }

    func body(content: Content) -> some View {
        hNavigationStack(router: router, options: options, tracking: tracking) {
            content
                .environmentObject(router)
        }
    }
}

extension View {
    @ViewBuilder
    @MainActor public func configureTitleView(
        title: String,
        subTitle: String? = nil,
        titleColor: TitleColor? = nil,
        topPadding: CGFloat = .padding8,
        onTitleTap: (() -> Void)? = nil
    ) -> some View {
        if #available(iOS 26.0, *), isLiquidGlassEnabled {
            self.toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        onTitleTap?()
                    } label: {
                        titleView(
                            title: title,
                            subTitle: subTitle,
                            topPadding: topPadding,
                            titleColor: titleColor ?? .default
                        )
                        .fixedSize()
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
                    topPadding: topPadding,
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
        topPadding: CGFloat,
        onTitleTap: (() -> Void)? = nil
    ) -> UIView {
        let view: UIView = UIHostingController(
            rootView: titleView(title: title, subTitle: subTitle, topPadding: topPadding, titleColor: titleColor)
                .onTapGesture {
                    onTitleTap?()
                }
                .accessibilityAddTraits(.isButton)
        )
        .view
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        return view
    }

    @ViewBuilder
    private func titleView(title: String, subTitle: String?, topPadding: CGFloat, titleColor: TitleColor) -> some View {
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
        .padding(.top, topPadding)
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
