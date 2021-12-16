//
//  Future+Sink.swift
//  hCore
//
//  Created by Sam Pettersson on 2021-12-16.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import Flow

extension Future {
    /// calls on value on the future, and never notifies you, effectively swallowing its value
    @discardableResult public func sink() -> Future<Value> {
        self.onValue { _ in }
    }
}
