//
//  Viewable+WrappedIn.swift
//  Core
//
//  Created by Sam Pettersson on 2020-05-08.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

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

    public func materialize(events _: ViewableEvents) -> (ContainerView, Signal<SignalValue>) {
        return (container, Signal { callback in
            let bag = DisposeBag()
            bag += self.container.addArranged(self.viewable).onValue(callback)
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

extension Viewable where Self.Events == ViewableEvents, Self.Result == Disposable, Self.Matter: UIView {
    public func wrappedIn(_ stackView: UIStackView, configure: @escaping (_ view: Self.Matter) -> Void = { _ in }) -> ContainerStackViewable<Self, Self.Matter, UIStackView> {
        ContainerStackViewable(viewable: self, container: stackView, configure: configure)
    }

    public func wrappedIn(_ view: UIView, configure: @escaping (_ view: Self.Matter) -> Void = { _ in }) -> ContainerViewable<Self, Self.Matter, UIView> {
        ContainerViewable(viewable: self, container: view, configure: configure)
    }
}

extension Viewable where Self.Events == ViewableEvents, Self.Matter: UIView {
    public func wrappedIn<SignalValue>(_ stackView: UIStackView) -> ContainerStackViewableSignal<Self, Self.Matter, UIStackView, SignalValue> {
        ContainerStackViewableSignal(viewable: self, container: stackView)
    }
}
