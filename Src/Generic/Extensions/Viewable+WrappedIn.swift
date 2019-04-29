//
//  Viewable+WrappedIn.swift
//  project
//
//  Created by Sam Pettersson on 2019-04-23.
//

import Foundation
import UIKit
import Flow

struct ContainerViewable<V: Viewable, Matter: UIView>: Viewable where V.Matter == Matter, V.Events == ViewableEvents, V.Result == Disposable {
    let viewable: V
    let container: UIStackView
    
    func materialize(events: ViewableEvents) -> (UIStackView, Disposable) {
        let bag = DisposeBag()
        bag += container.addArranged(viewable)
        return (container, bag)
    }
}

extension Viewable where Self.Events == ViewableEvents, Self.Result == Disposable, Self.Matter: UIView {
    func wrappedIn(_ stackView: UIStackView) -> ContainerViewable<Self, Self.Matter> {
        return ContainerViewable(viewable: self, container: stackView)
    }
}
