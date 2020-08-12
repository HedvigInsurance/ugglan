//
//  Date+CurrentMilliseconds.swift
//  hCore
//
//  Created by Sam Pettersson on 2020-08-10.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation

extension Date {
    public var currentTimeMillis: Int64 {
        return Int64(timeIntervalSince1970 * 1000)
    }
}
