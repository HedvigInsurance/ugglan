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
    func add(_ viewable: Viewable, onCreate: (_ view: UIView) -> Void = defaultOnCreateClosure) -> Disposable {
        let wasAddedCallbacker = Callbacker<Void>()
        let willRemoveCallbacker = Callbacker<Void>()
        let viewableEvents = ViewableEvents(
            wasAddedCallbacker: wasAddedCallbacker,
            willRemoveCallbacker: willRemoveCallbacker
        )
        let (view, disposable) = viewable.materialize(events: viewableEvents)

        addSubview(view)
        onCreate(view)

        wasAddedCallbacker.callAll()

        return Disposer {
            let bag = DisposeBag()
            let removeAfter = viewableEvents.removeAfter.call() ?? 0
            willRemoveCallbacker.callAll()
            bag += Signal(after: removeAfter).onValue {
                view.removeFromSuperview()
                bag.dispose()
                disposable.dispose()
            }
        }
    }
}

extension UIStackView {
    func addArangedSubview(_ viewable: Viewable, onCreate: (_ view: UIView) -> Void = defaultOnCreateClosure) -> Disposable {
        let wasAddedCallbacker = Callbacker<Void>()
        let willRemoveCallbacker = Callbacker<Void>()
        let viewableEvents = ViewableEvents(
            wasAddedCallbacker: wasAddedCallbacker,
            willRemoveCallbacker: willRemoveCallbacker
        )
        let (view, disposable) = viewable.materialize(events: viewableEvents)

        addArrangedSubview(view)
        onCreate(view)

        wasAddedCallbacker.callAll()

        return Disposer {
            let bag = DisposeBag()
            let removeAfter = viewableEvents.removeAfter.call() ?? 0
            willRemoveCallbacker.callAll()
            bag += Signal(after: removeAfter).onValue {
                view.removeFromSuperview()
                bag.dispose()
                disposable.dispose()
            }
        }
    }
}
