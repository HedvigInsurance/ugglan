//
//  TakeLeft-Right.swift
//  hCore
//
//  Created by Sam Pettersson on 2020-08-17.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation

public func takeRight<T>(lhs _: T, rhs: T) -> T {
    rhs
}

public func takeLeft<T>(lhs: T, rhs _: T) -> T {
    lhs
}
