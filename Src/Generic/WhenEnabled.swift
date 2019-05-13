//
//  WhenEnabled.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-05-13.
//

import Foundation
import Flow
import UIKit

struct WhenEnabled<V: Viewable>: Viewable where V.Events == ViewableEvents, V.Matter: UIView, V.Result == Disposable {
    let getViewable: () -> V
    let enabledSignal: ReadWriteSignal<Bool>
    
    init(_ enabledSignal: ReadWriteSignal<Bool>, _ getViewable: @escaping () -> V) {
        self.enabledSignal = enabledSignal
        self.getViewable = getViewable
    }
    
    func materialize(events: ViewableEvents) -> (UIStackView, Disposable) {
        let bag = DisposeBag()
        let view = UIStackView()
        
        bag += view.didMoveToWindowSignal.take(first: 1).onValue { _ in
            view.snp.makeConstraints({ make in
                make.trailing.leading.equalToSuperview()
            })
        }
        
        bag += enabledSignal.atOnce().wait(until: view.hasWindowSignal).onValueDisposePrevious { enabled -> Disposable? in
            if enabled {
                return view.addArranged(self.getViewable())
            } else {
                return NilDisposer()
            }
        }
        
        return (view, bag)
    }
}
