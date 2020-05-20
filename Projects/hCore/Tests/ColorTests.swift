//
//  ColorTests.swift
//  Core
//
//  Created by Sam Pettersson on 2020-05-07.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import XCTest
import UIKit
import hCore

final class ColorTests: XCTestCase {
    func testHedvigColors() {
        let view = UIView()
        view.backgroundColor = .hedvig(.primaryTintColor)
    }
    
    func testDynamicPolyfill() {
        let color = UIColor { trait -> UIColor in
            trait.userInterfaceStyle == .dark ? .black : .white
        }
                
        XCTAssert(
            color.resolvedColor(
                with: UITraitCollection(userInterfaceStyle: .dark)
            ).cgColor == UIColor.black.cgColor
        )
        XCTAssert(
            color.resolvedColor(
                with: UITraitCollection(userInterfaceStyle: .light)
            ).cgColor == UIColor.white.cgColor
        )
    }
}
