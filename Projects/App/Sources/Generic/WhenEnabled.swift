//
//  WhenEnabled.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-05-13.
//

import Flow
import Foundation
import UIKit
import Core

struct WhenEnabled<V: Viewable>: Viewable where V.Events == ViewableEvents, V.Matter: UIView, V.Result == Disposable {
    let getViewable: () -> V
    let onCreate: (_ view: V.Matter) -> Void
    let enabledSignal: ReadSignal<Bool>

    init(
        _ enabledSignal: ReadSignal<Bool>,
        _ getViewable: @escaping () -> V,
        _ onCreate: @escaping (_ view: V.Matter) -> Void = { _ in }
    ) {
        self.enabledSignal = enabledSignal
        self.getViewable = getViewable
        self.onCreate = onCreate
    }

    func materialize(events _: ViewableEvents) -> (UIStackView, Disposable) {
        let bag = DisposeBag()
        let view = UIStackView()

        bag += view.didMoveToWindowSignal.take(first: 1).onValue { _ in
            view.snp.makeConstraints { make in
                make.trailing.leading.equalToSuperview()
            }
        }

        bag += enabledSignal.atOnce().wait(until: view.hasWindowSignal).onValueDisposePrevious { enabled -> Disposable? in
            if enabled {
                return view.addArranged(self.getViewable(), onCreate: self.onCreate)
            } else {
                return NilDisposer()
            }
        }

        return (view, bag)
    }
}
