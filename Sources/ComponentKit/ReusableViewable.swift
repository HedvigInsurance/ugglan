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

public struct ReusableDisposableViewable<View: Viewable>: Reusable where View.Events == ViewableEvents, View.Matter: UIView, View.Result == Disposable {
    public let viewable: View

    public static func makeAndConfigure() -> (make: UIView, configure: (Self) -> Disposable) {
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

public struct ReusableSignalViewable<View: Viewable, SignalValue>: Reusable, SignalProvider where View.Events == ViewableEvents, View.Matter: UIView, View.Result == Signal<SignalValue> {
    public init(viewable: View) {
        self.viewable = viewable
    }
    
    public let viewable: View
    public var providedSignal: Signal<SignalValue> {
        callbacker.providedSignal
    }

    private let callbacker = Callbacker<SignalValue>()

    public static func makeAndConfigure() -> (make: UIView, configure: (Self) -> Disposable) {
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
    public static func == (_: ReusableSignalViewable<View, SignalValue>, _: ReusableSignalViewable<View, SignalValue>) -> Bool {
        return true
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(true)
    }
}
