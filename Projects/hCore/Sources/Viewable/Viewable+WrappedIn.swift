import Flow
import Foundation
import UIKit

public struct ContainerStackViewable<V: Viewable, Matter: UIView, ContainerView: UIStackView>: Viewable where V.Matter == Matter, V.Events == ViewableEvents, V.Result == Disposable {
    let viewable: V
    let container: ContainerView
    let configure: (_ view: Matter) -> Void

    public func materialize(events _: ViewableEvents) -> (ContainerView, Disposable) {
        let bag = DisposeBag()
        bag += container.addArranged(viewable, onCreate: configure)
        return (container, bag)
    }
}

public struct ContainerStackViewableSignal<V: Viewable, Matter: UIView, ContainerView: UIStackView, SignalValue>: Viewable where V.Matter == Matter, V.Events == ViewableEvents, V.Result == Signal<SignalValue> {
    let viewable: V
    let container: ContainerView
    let configure: (_ view: Matter) -> Void

    public func materialize(events _: ViewableEvents) -> (ContainerView, Signal<SignalValue>) {
        return (container, Signal { callback in
            let bag = DisposeBag()
            bag += self.container.addArranged(self.viewable, onCreate: configure).onValue(callback)
            return bag
        })
    }
}

public struct ContainerViewable<V: Viewable, Matter: UIView, ContainerView: UIView>: Viewable where V.Matter == Matter, V.Events == ViewableEvents, V.Result == Disposable {
    let viewable: V
    let container: ContainerView
    let configure: (_ view: Matter) -> Void

    public func materialize(events _: ViewableEvents) -> (ContainerView, Disposable) {
        let bag = DisposeBag()
        bag += container.add(viewable, onCreate: configure)
        return (container, bag)
    }
}

public extension Viewable where Self.Events == ViewableEvents, Self.Result == Disposable, Self.Matter: UIView {
    typealias StackContainer = ContainerStackViewable<Self, Self.Matter, UIStackView>

    func wrappedIn(_ stackView: UIStackView, configure: @escaping (_ view: Self.Matter) -> Void = { _ in }) -> StackContainer {
        ContainerStackViewable(viewable: self, container: stackView, configure: configure)
    }

    func insetted(
        _ layoutMargins: UIEdgeInsets,
        configure: @escaping (_ matter: Self.Matter) -> Void = { _ in }
    ) -> StackContainer {
        wrappedIn({
            let stackView = UIStackView()
            stackView.layoutMargins = layoutMargins
            stackView.isLayoutMarginsRelativeArrangement = true
            stackView.insetsLayoutMarginsFromSafeArea = false
            return stackView
        }(), configure: configure)
    }

    func alignedTo(
        alignment: UIStackView.Alignment,
        configure: @escaping (_ matter: Self.Matter) -> Void = { _ in }
    ) -> ContainerStackViewable<StackContainer, UIStackView, UIStackView> {
        wrappedIn({
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.alignment = alignment
            stackView.distribution = .equalSpacing
            return stackView
        }(), configure: configure).wrappedIn({
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.distribution = .equalSpacing
            stackView.alignment = alignment
            return stackView
        }())
    }

    typealias Container = ContainerViewable<Self, Self.Matter, UIView>

    func wrappedIn(_ view: UIView, configure: @escaping (_ view: Self.Matter) -> Void = { _ in }) -> Container {
        ContainerViewable(viewable: self, container: view, configure: configure)
    }
}

public extension Viewable where Self.Events == ViewableEvents, Self.Matter: UIView {
    func wrappedIn<SignalValue>(_ stackView: UIStackView, configure: @escaping (_ view: Self.Matter) -> Void = { _ in }) -> ContainerStackViewableSignal<Self, Self.Matter, UIStackView, SignalValue> {
        ContainerStackViewableSignal(viewable: self, container: stackView, configure: configure)
    }

    func insetted<SignalValue>(_ layoutMargins: UIEdgeInsets) -> ContainerStackViewableSignal<Self, Self.Matter, UIStackView, SignalValue> {
        wrappedIn({
            let stackView = UIStackView()
            stackView.layoutMargins = layoutMargins
            stackView.isLayoutMarginsRelativeArrangement = true
            stackView.insetsLayoutMarginsFromSafeArea = false
            return stackView
        }())
    }

    func alignedTo<SignalValue>(
        alignment: UIStackView.Alignment,
        configure: @escaping (_ matter: Self.Matter) -> Void = { _ in }
    ) -> ContainerStackViewableSignal<ContainerStackViewableSignal<Self, Self.Matter, UIStackView, SignalValue>, UIStackView, UIStackView, SignalValue> {
        wrappedIn({
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.alignment = alignment
            stackView.distribution = .equalSpacing
            return stackView
        }(), configure: configure).wrappedIn({
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.distribution = .equalSpacing
            stackView.alignment = .leading
            return stackView
        }())
    }
}
