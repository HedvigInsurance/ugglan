import Foundation
import Introspect
import SwiftUI

struct RefreshAction {

    let action: () async -> Void

    func callAsFunction() async {
        await action()
    }
}

struct RefreshActionKey: EnvironmentKey {

    static let defaultValue: RefreshAction? = nil
}

extension EnvironmentValues {

    var refresh: RefreshAction? {
        get { self[RefreshActionKey.self] }
        set { self[RefreshActionKey.self] = newValue }
    }
}

struct RefreshableModifier: ViewModifier {

    let action: () async -> Void

    func body(content: Content) -> some View {
        content
            .environment(\.refresh, RefreshAction(action: action))
            .onRefresh { refreshControl in
                Task {
                    await action()
                    refreshControl.endRefreshing()
                }
            }
    }
}

extension View {

    @ViewBuilder
    public func onRefresh(action: @escaping @Sendable () async -> Void) -> some View {
        if #available(iOS 15.0, *) {
            self.refreshable {
                await action()
            }
        } else {
            self.modifier(RefreshableModifier(action: action))
        }
    }
}

extension UIScrollView {

    struct Keys {
        static var onValueChanged: UInt8 = 0
    }

    public typealias ValueChangedAction = ((_ refreshControl: UIRefreshControl) -> Void)

    var onValueChanged: ValueChangedAction? {
        get {
            objc_getAssociatedObject(self, &Keys.onValueChanged) as? ValueChangedAction
        }
        set {
            objc_setAssociatedObject(self, &Keys.onValueChanged, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    public func onRefresh(_ onValueChanged: @escaping ValueChangedAction) {
        if refreshControl == nil {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(
                self,
                action: #selector(self.onValueChangedAction),
                for: .valueChanged
            )
            self.refreshControl = refreshControl
        }
        self.onValueChanged = onValueChanged
    }

    @objc func onValueChangedAction(sender: UIRefreshControl) {
        self.onValueChanged?(sender)
    }
}

struct OnListRefreshModifier: ViewModifier {

    let onValueChanged: UIScrollView.ValueChangedAction

    func body(content: Content) -> some View {
        content
            .introspectTableView { tableView in
                tableView.onRefresh(onValueChanged)
            }
    }
}

extension View {

    public func onRefresh(onValueChanged: @escaping UIScrollView.ValueChangedAction) -> some View {
        self.modifier(OnListRefreshModifier(onValueChanged: onValueChanged))
    }
}
