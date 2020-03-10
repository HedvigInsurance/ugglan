//
//  DelayedDisposer.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-12-18.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Flow
import Foundation

public struct DelayedDisposer: Disposable {
    public let disposable: Disposable
    public let delay: TimeInterval
    private let onDisposeCallbacker: Callbacker<Void>
    public let onDisposeSignal: Signal<Void>
    public let bag: DisposeBag

    public func dispose() {
        bag += Signal(after: delay).onValue { () in
            self.bag.dispose()
            self.disposable.dispose()
        }
    }

    public init(_ disposable: Disposable, delay: TimeInterval) {
        onDisposeCallbacker = Callbacker<Void>()
        onDisposeSignal = onDisposeCallbacker.providedSignal
        bag = DisposeBag()
        self.delay = delay
        self.disposable = disposable
    }
}
