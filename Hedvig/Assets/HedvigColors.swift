//
//  Colors.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-11.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Foundation
import UIKit
import DynamicColor

struct HedvigColors {
    static let transparent = UIColor.white.withAlphaComponent(0)
    static let white = UIColor.white
    static let black = UIColor.black
    static let turquoise = UIColor(red: 0.11, green: 0.91, blue: 0.71, alpha: 1.0)
    static let purple = UIColor(red: 0.40, green: 0.12, blue: 1.00, alpha: 1.0)
    static let darkPurple = UIColor(red: 0.03, green: 0.02, blue: 0.27, alpha: 1.0)
    static let blackPurple = UIColor(red: 0.06, green: 0.00, blue: 0.48, alpha: 1.0)
    static let darkGray = UIColor(red: 0.61, green: 0.61, blue: 0.67, alpha: 1.0)
    static let lightGray = UIColor(red: 0.91, green: 0.93, blue: 0.94, alpha: 1.0)
    static let offBlack = UIColor(red: 0.25, green: 0.25, blue: 0.31, alpha: 1.0)
    static let offWhite = UIColor(red: 0.98, green: 0.98, blue: 0.99, alpha: 1.0)
    static let green = UIColor(red: 0.11, green: 0.91, blue: 0.71, alpha: 1.0)
    static let pink = UIColor(red: 1.00, green: 0.54, blue: 0.50, alpha: 1.0)
    static let grayBorder = HedvigColors.darkGray.lighter(amount: 0.15).withAlphaComponent(0.3)
}
