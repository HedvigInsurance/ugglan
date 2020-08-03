//
//  CoreSignal+Boolean.swift
//  hCore
//
//  Created by sam on 3.8.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import Flow

public extension CoreSignal {
    /// returns a signal that maps current signal to a readable signal with an initial value of false, maps to true after first value
    func boolean() -> CoreSignal<Read, Bool> {
        return map { _ in true }.plain().readable(initial: false)
    }
}
