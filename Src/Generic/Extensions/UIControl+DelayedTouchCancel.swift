//
//  UIControl+DelayedTouchCancel.swift
//  Ugglan
//
//  Created by Gustaf Gunér on 2019-05-29.
//

import Flow
import Foundation
import UIKit

extension UIControl {
    func delayedTouchCancel(delay: Double = 0.2) -> Signal<Bool> {
        return Signal { callback in
            let bag = DisposeBag()
            
            let touchDownDateSignal = ReadWriteSignal<Date>(Date())
            
            bag += self
                .signal(for: .touchDown)
                .map { Date() }
                .bindTo(touchDownDateSignal)
            
            bag += merge(
                self.signal(for: .touchUpInside),
                self.signal(for: .touchUpOutside),
                self.signal(for: .touchCancel)
                ).withLatestFrom(touchDownDateSignal.atOnce().plain())
                .delay(by: { _, date in date.timeIntervalSinceNow < -delay ? 0 : delay })
                .onValue({ _ in
                    callback(true)
                })
            
            return bag
        }
    }
}
