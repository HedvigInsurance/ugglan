//
//  Either+Make.swift
//  project
//
//  Created by Sam Pettersson on 2019-09-02.
//

import Flow
import Foundation

extension Either {
    static func make(_ value: Left) -> Self {
        return .left(value)
    }

    static func make(_ value: Right) -> Self {
        return .right(value)
    }
}
