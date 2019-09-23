//
//  ReusableViewable.swift
//  test
//
//  Created by Sam Pettersson on 2019-09-23.
//

import Foundation
import Flow
import Form
import UIKit

struct ReusableViewable<View: Viewable, SignalValue>: Reusable where View.Events == ViewableEvents, View.Matter: UIView, View.Result == Signal<SignalValue> {
    let viewable: View
    var signal: Signal<SignalValue> {
        callbacker.providedSignal
    }
    
    private let callbacker = Callbacker<SignalValue>()
    
    static func makeAndConfigure() -> (make: UIView, configure: (ReusableViewable) -> Disposable) {
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
