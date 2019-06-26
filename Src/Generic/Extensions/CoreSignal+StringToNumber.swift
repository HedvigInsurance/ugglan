//
//  CoreSignal+StringToNumber.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-06-24.
//

import Flow
import Foundation

extension CoreSignal where Value == String? {
    func toInt() -> CoreSignal<Kind.DropWrite, Int?> {
        return map { amount -> Int? in
            if let amount = amount, let double = Double(amount) {
                return Int(double)
            }

            return nil
        }
    }
}
