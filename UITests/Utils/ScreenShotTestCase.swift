//
//  ScreenShotTestCase.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-07-22.
//

import Apollo
import SnapshotTesting
import Flow
import UIKit
import XCTest
import Presentation
import Form

class SnapShotTestCase: XCTestCase {
    override func setUp() {
        super.setUp()
        
        FontLoader.loadFonts()
        DefaultStyling.installCustom()
        
        #if RECORD_MODE
        record = true
        #endif
    }
}
