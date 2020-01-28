//
//  KeyGearAddButton.swift
//  test
//
//  Created by Sam Pettersson on 2020-01-27.
//

import Foundation
import Flow
import Form
import UIKit

struct KeyGearAddButton {}

extension KeyGearAddButton: Viewable {
    func materialize(events: ViewableEvents) -> (UIControl, Signal<Void>) {
        let view = UIControl()
        view.layer.cornerRadius = 8
        view.backgroundColor = .purple
        
        let bag = DisposeBag()
        
        return (view, Signal { callback in
            bag += view.signal(for: .touchUpInside).onValue { _ in
                callback(())
            }
            
            return bag
        })
    }
}
