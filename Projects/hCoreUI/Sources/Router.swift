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
    fileprivate var onPush: ((AnyView) -> Void)?
    fileprivate var onPop: (() -> Void)?
    fileprivate var onPopToRoot: (() -> Void)?

    public init() {}

    var builders: [String: (AnyHashable) -> AnyView?] = [:]
    public func push<T>(_ route: T) where T: Hashable {
        routes.append(route)
        if let builder = builders["\(T.self)"], let view = builder(route) {
            onPush?(view)
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
        router.onPush = { [weak router, weak navigation] view in guard let router = router else { return }
            navigation?
                .pushViewController(
                    hHostingController(rootView: view.environmentObject(router)),
                    animated: true
                )
        }

        router.onPop = { [weak navigation] in
            navigation?.popViewController(animated: true)
        }

        router.onPopToRoot = { [weak navigation] in
            navigation?.popToRootViewController(animated: true)
        }
        navigation.onDeinit = { [weak router] in
            router?.builders.removeAll()
        }
        return navigation
    }

    public func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
    public typealias UIViewControllerType = UINavigationController
}

extension View {
    public func routerDestination<D, C>(for data: D.Type, @ViewBuilder destination: @escaping (D) -> C) -> some View
    where D: Hashable, C: View {
        modifier(RouterDestinationModifier(for: data, destination: destination))
    }
}

struct RouterDestinationModifier<D, C>: ViewModifier where D: Hashable, C: View {
    @EnvironmentObject var router: Router

    @ViewBuilder
    var destination: (D) -> C
    init(for data: D.Type, destination: @escaping (D) -> C) {
        self.destination = destination
    }
    func body(content: Content) -> some View {
        content
            .onAppear { [weak router] in
                router?.builders["\(D.self)"] = { item in
                    return AnyView(destination(item as! D))
                }
            }
    }
}
