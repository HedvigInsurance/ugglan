//
//  DelayedDisposer.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-12-18.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Flow
import Foundation

struct DelayedDisposer: Disposable {
    let disposable: Disposable
    let delay: TimeInterval
    private let onDisposeCallbacker: Callbacker<Void>
    let onDisposeSignal: Signal<Void>
    let bag: DisposeBag

    func dispose() {
        bag += Signal(after: delay).onValue { () in
            self.bag.dispose()
            self.disposable.dispose()
        }
    }

    init(_ disposable: Disposable, delay: TimeInterval) {
        onDisposeCallbacker = Callbacker<Void>()
        onDisposeSignal = onDisposeCallbacker.signal()
        bag = DisposeBag()
        self.delay = delay
        self.disposable = disposable
    }
}
