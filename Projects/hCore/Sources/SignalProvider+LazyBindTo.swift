//
//  SignalProvider+LazyBindTo.swift
//  Core
//
//  Created by Sam Pettersson on 2020-05-08.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Flow

extension SignalProvider {
    /// Lazily bind to a callbacker, useful if you wanna build a generic component that
    /// necesairily doesnt always listen to a Signal.
    public func lazyBindTo(callbacker: Callbacker<Value>) -> Disposable {
        let bag = DisposeBag()

        if !callbacker.isEmpty {
            bag += onValue { value in
                callbacker.callAll(with: value)
            }
        } else {
            var hasAddedListener = false

            callbacker.didAddCallbacker = {
                guard hasAddedListener == false else {
                    callbacker.didAddCallbacker = nil
                    return
                }

                hasAddedListener = true

                bag += self.onValue { value in
                    callbacker.callAll(with: value)
                }
            }
        }

        return Disposer {
            callbacker.didAddCallbacker = nil
            bag.dispose()
        }
    }
}
