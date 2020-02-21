//
//  ReusableViewable.swift
//  test
//
//  Created by Sam Pettersson on 2019-09-23.
//

import Flow
import Form
import Foundation
import UIKit

struct ReusableDisposableViewable<View: Viewable>: Reusable where View.Events == ViewableEvents, View.Matter: UIView, View.Result == Disposable {
    let viewable: View

    static func makeAndConfigure() -> (make: UIView, configure: (Self) -> Disposable) {
        let containerView = UIView()

        return (containerView, { anyReusable in
            let bag = DisposeBag()

            bag += containerView.add(anyReusable.viewable) { view in
                view.snp.remakeConstraints { make in
                    make.top.bottom.trailing.leading.equalToSuperview()
                }
            }

            return bag
        })
    }
}

struct ReusableSignalViewable<View: Viewable, SignalValue>: Reusable, SignalProvider where View.Events == ViewableEvents, View.Matter: UIView, View.Result == Signal<SignalValue> {
    let viewable: View
    var providedSignal: Signal<SignalValue> {
        callbacker.providedSignal
    }

    private let callbacker = Callbacker<SignalValue>()

    static func makeAndConfigure() -> (make: UIView, configure: (Self) -> Disposable) {
        let containerView = UIView()

        return (containerView, { anyReusable in
            let bag = DisposeBag()

            bag += containerView.add(anyReusable.viewable) { view in
                view.snp.remakeConstraints { make in
                    make.top.bottom.trailing.leading.equalToSuperview()
                }
            }.onValue { value in anyReusable.callbacker.callAll(with: value) }

            return bag
        })
    }
}

extension ReusableSignalViewable: Hashable {
    static func == (lhs: ReusableSignalViewable<View, SignalValue>, rhs: ReusableSignalViewable<View, SignalValue>) -> Bool {
        return true
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(true)
    }
}
