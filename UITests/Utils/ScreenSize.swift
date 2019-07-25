//
//  ScreenSize.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-07-22.
//

import Foundation
import UIKit

struct ScreenSize {
    static let iPhoneX = ScreenSize(width: 375, height: 812)
    static let iPhone7 = ScreenSize(width: 375, height: 667)
    static let iPadPro105 = ScreenSize(width: 1112, height: 834)

    var frame: CGRect {
        return CGRect(x: 0, y: 0, width: width, height: height)
    }

    var window: UIWindow {
        return UIWindow(frame: frame)
    }

    let width: CGFloat
    let height: CGFloat
}
