//
//  KeyGearListItem.swift
//  test
//
//  Created by Sam Pettersson on 2020-01-27.
//

import Foundation
import Flow
import Form

struct KeyGearListItem {
    let id: String
    let imageUrl: URL?
    let wasAddedAutomatically: Bool
    
    private let callbacker = Callbacker<Void>()
}


extension KeyGearListItem: SignalProvider {
    var providedSignal: Signal<Void> {
        return callbacker.providedSignal
    }
}


extension KeyGearListItem: Reusable {
    static func makeAndConfigure() -> (make: UIControl, configure: (KeyGearListItem) -> Disposable) {
        let view = UIControl()
        view.layer.cornerRadius = 8
        view.backgroundColor = .sunflower300
        return (view, { `self` in
            let bag = DisposeBag()
            
            bag += view.signal(for: .touchUpInside).onValue { _ in
                self.callbacker.callAll()
            }
            
            return bag
        })
    }
}
