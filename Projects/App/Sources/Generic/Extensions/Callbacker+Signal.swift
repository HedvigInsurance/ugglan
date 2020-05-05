//
//  Callbacker+Signal.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-12-02.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Flow
import Foundation

extension Callbacker {
    /// Returns a new singal from self
    func signal() -> CoreSignal<Plain, Value> {
        return Signal(callbacker: self)
    }
}
