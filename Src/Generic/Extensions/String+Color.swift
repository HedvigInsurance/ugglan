//
//  String+Color.swift
//  project
//
//  Created by Sam Pettersson on 2019-06-03.
//

import Foundation
import UIKit

extension String {
    // gives a hash that is deterministic across app launches
    var deterministicHash: Int {
        var result = UInt64(5381)
        let buf = [UInt8](utf8)
        for b in buf {
            result = 127 * (result & 0x00FF_FFFF_FFFF_FFFF) + UInt64(b)
        }
        return Int(result)
    }

    // gives a color for the current string value
    var hedvigColor: UIColor {
        let colors = [
            UIColor.purple,
            UIColor.darkPurple,
            UIColor.turquoise,
            UIColor.darkGreen,
            UIColor.pink,
            UIColor.darkPink,
            UIColor.yellow
        ]

        return colors[abs(self.deterministicHash) % colors.count]
    }
}
