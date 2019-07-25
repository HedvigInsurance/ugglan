//
//  SendButton.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-07-25.
//

import Foundation
import Flow
import UIKit

struct SendButton {}

extension SendButton: Viewable {
    func materialize(events: ViewableEvents) -> (UIControl, Signal<Void>) {
        let bag = DisposeBag()
        let control = UIControl()
        control.backgroundColor = .purple
        control.layer.cornerRadius = 15
        
        control.snp.makeConstraints { make in
            make.width.height.equalTo(30)
        }
        
        return (control, Signal { callback in
            bag += control.signal(for: .touchUpInside).onValue(callback)
            return bag
        })
    }
}
