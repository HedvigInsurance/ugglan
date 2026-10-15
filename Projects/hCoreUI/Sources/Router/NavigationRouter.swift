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
@Observable
public class NavigationRouter {
    fileprivate var path = NavigationPath() {
        didSet {
            // SwiftUI writes `path` itself when the member swipes or taps back, so the parallel
            // route-type stack is trimmed from here rather than from pop(). Deferred to the next
            // main-actor turn because that write usually lands inside a view update, and
            // routeTypes is observed too.
            Task { @MainActor [weak self] in
                guard let self, self.path.count < self.routeTypes.count else { return }
                self.routeTypes.removeLast(self.routeTypes.count - self.path.count)
            }
        }
    }
    public private(set) var routeTypes: [Any.Type] = []
    @ObservationIgnored var onDismiss: ((_ withDismissingAll: Bool) -> Void)?

    public init() {}

    public func push<T>(_ route: T) where T: Hashable & TrackingViewNameProtocol {
        routeTypes.append(T.self)
        path.append(route)
    }

    public func pop<T>(_ hash: T.Type) {
        guard !path.isEmpty else { return }
        routeTypes.removeLast()
        path.removeLast()
    }

    public func pop<T>(_ view: T) where T: View {
        guard !path.isEmpty else { return }
        routeTypes.removeLast()
        path.removeLast()
    }

    public func pop() {
        guard !path.isEmpty else { return }
        routeTypes.removeLast()
        path.removeLast()
    }

    public func popToRoot() {
        routeTypes.removeAll()
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

/// Forces the navigation bar visibility the options ask for. With `.ignoreNavigationBarVisibility`
/// it applies nothing at all, leaving the root screen in charge of its own bar: even a
/// `.toolbar(.automatic, for: .navigationBar)` on the root swallows every visibility change the
/// screen makes later from inside (observed on iOS 27.1), so the host must not touch it.
private struct NavigationBarVisibilityModifier: ViewModifier {
    let options: RouterOptions

    func body(content: Content) -> some View {
        if options.contains(.ignoreNavigationBarVisibility) {
            content
        } else {
            content.toolbar(options.contains(.navigationBarHidden) ? .hidden : .visible, for: .navigationBar)
        }
    }
}

public struct hNavigationStack<Screen: View>: View {
    @Bindable var router: NavigationRouter
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
                .modifier(NavigationBarVisibilityModifier(options: options))
                .trackNavigation(name: tracking.nameForTracking)
        }
        .introspect(.navigationStack, on: .iOS(.v16...)) { navController in
            hNavigationStack.applyCustomStyling(to: navController, options: options)
            hNavigationStack.wireUpDismiss(navController: navController, router: router)
        }
        .environment(router)
    }

    private static func applyCustomStyling(to navController: UINavigationController, options: RouterOptions) {
        if options.contains(.navigationBarHidden) {
            navController.setNavigationBarHidden(true, animated: false)
        }

        if options.contains(.largeNavigationBar) {
            object_setClass(navController.navigationBar, LargeNavBar.self)
            if #unavailable(iOS 26.0), options.contains(.extendedNavigationWidth) {
                (navController.navigationBar as? LargeNavBar)?.extendedNavigationWidth = true
            }
            navController.additionalSafeAreaInsets.top =
                hNavigationControllerWithLargerNavBar.navigationBarHeight - 44
        } else {
            object_setClass(navController.navigationBar, NavBar.self)
            if #unavailable(iOS 26.0), options.contains(.extendedNavigationWidth) {
                (navController.navigationBar as? NavBar)?.extendedNavigationWidth = true
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
    @State var router = NavigationRouter()
    let options: RouterOptions
    let tracking: TrackingViewNameProtocol

    init(options: RouterOptions, tracking: TrackingViewNameProtocol, router: NavigationRouter? = nil) {
        if let router {
            _router = State(wrappedValue: router)
        }
        self.options = options
        self.tracking = tracking
    }

    func body(content: Content) -> some View {
        hNavigationStack(router: router, options: options, tracking: tracking) {
            content
                .environment(router)
        }
    }
}

extension HorizontalAlignment {
    fileprivate var toolbarItemPlacement: ToolbarItemPlacement {
        switch self {
        case .center: return .title
        case .leading: return .topBarLeading
        case .trailing: return .topBarTrailing
        default: return .title
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
        alignment: HorizontalAlignment = .leading,
        onTitleTap: (() -> Void)? = nil
    ) -> some View {
        if #available(iOS 26.0, *) {
            self.toolbar {
                ToolbarItem(placement: alignment.toolbarItemPlacement) {
                    Button {
                        onTitleTap?()
                    } label: {
                        titleView(
                            title: title,
                            subTitle: subTitle,
                            topPadding: topPadding,
                            titleColor: titleColor ?? .default,
                            alignment: alignment
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
                    alignment: alignment,
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
        alignment: HorizontalAlignment = .leading,
        onTitleTap: (() -> Void)? = nil
    ) -> UIView {
        let view: UIView = UIHostingController(
            rootView: titleView(
                title: title,
                subTitle: subTitle,
                topPadding: topPadding,
                titleColor: titleColor,
                alignment: alignment
            )
            .frame(maxWidth: .infinity, alignment: Alignment(horizontal: alignment, vertical: .center))
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
    private func titleView(
        title: String,
        subTitle: String?,
        topPadding: CGFloat,
        titleColor: TitleColor,
        alignment: HorizontalAlignment = .leading
    ) -> some View {
        Group {
            if let subTitle {
                VStack(alignment: alignment, spacing: 0) {
                    hText(title, style: .heading1)
                        .foregroundColor(titleViewColor(titleColor))
                        .accessibilityAddTraits(.isHeader)
                        .animation(nil, value: true)
                    hText(subTitle, style: .heading1)
                        .foregroundColor(hTextColor.Opaque.secondary)
                        .animation(.easeInOut(duration: 0.2), value: subTitle)
                }
                .animation(nil, value: true)
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
