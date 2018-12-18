//
//  UIView+Viewable.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-29.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import UIKit

private let defaultOnCreateClosure: (_ view: UIView) -> Void = { _ in }

extension UIView {
    func add<V: Viewable>(_ viewable: V, onCreate: (_ view: UIView) -> Void = defaultOnCreateClosure) -> V.Result where V.Matter == UIView {
        let wasAddedCallbacker = Callbacker<Void>()
        let viewableEvents = ViewableEvents(
            wasAddedCallbacker: wasAddedCallbacker
        )
        let (view, matter) = viewable.materialize(events: viewableEvents)

        addSubview(view)
        onCreate(view)

        wasAddedCallbacker.callAll()

        return matter
    }
}

extension UIStackView {
    func addArangedSubview<V: Viewable>(_ viewable: V, onCreate: (_ view: UIView) -> Void = defaultOnCreateClosure) -> V.Result where V.Matter == UIView {
        let wasAddedCallbacker = Callbacker<Void>()
        let willRemoveCallbacker = Callbacker<Void>()
        let viewableEvents = ViewableEvents(
            wasAddedCallbacker: wasAddedCallbacker
        )
        let (view, matter) = viewable.materialize(events: viewableEvents)

        addArrangedSubview(view)
        onCreate(view)

        wasAddedCallbacker.callAll()

        return matter
    }
}
