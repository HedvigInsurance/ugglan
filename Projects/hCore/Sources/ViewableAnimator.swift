import Flow
import Foundation
import UIKit

public protocol ViewableAnimatorHandler {
    associatedtype Views
    associatedtype State
    func animate(animator: ViewableAnimator<Self>) -> ReadSignal<Bool>
}

public class ViewableAnimator<AnimatorHandler: ViewableAnimatorHandler> {
    public init(
        state: AnimatorHandler.State,
        handler: AnimatorHandler,
        views: AnimatorHandler.Views
    ) {
        self.handler = handler
        self.state = state
        self.views = views
    }

    private let handler: AnimatorHandler
    public var views: AnimatorHandler.Views
    public private(set) var state: AnimatorHandler.State

    public func setState(_ state: AnimatorHandler.State) -> ReadSignal<Bool> {
        self.state = state
        return handler.animate(animator: self)
    }

    public func register<View: UIView>(key: WritableKeyPath<AnimatorHandler.Views, View>, value: View) {
        views[keyPath: key] = value
    }
}

@propertyWrapper public struct ViewableAnimatedView<View: UIView> {
    private var inner: View?
    public var wrappedValue: View {
        get { inner ?? View() }
        set { inner = newValue }
    }

    public init() {}
}
