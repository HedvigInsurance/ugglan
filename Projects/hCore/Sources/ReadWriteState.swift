//
//  ReadWriteState.swift
//  hCore
//
//  Created by sam on 25.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import Flow

@propertyWrapper public struct ReadWriteState<T> {
    var signal: ReadWriteSignal<T>
    public var projectedValue: ReadWriteSignal<T> { signal }
    public var wrappedValue: T {
        get { signal.value }
        set {
            signal.value = newValue
        }
    }

    public init(wrappedValue value: T) {
        self.signal = ReadWriteSignal(value)
    }
}
