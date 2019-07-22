//
//  ScreenShotTestCase.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-07-22.
//

import Apollo
import FBSnapshotTestCase
import Flow
import UIKit
import XCTest
import Presentation
import Form

class ScreenShotTestCase: FBSnapshotTestCase {
    override func setUp() {
        super.setUp()
        
        FontLoader.loadFonts()
        DefaultStyling.installCustom()
        
        #if RECORD_MODE
        recordMode = true
        #endif
    }
    
    var screenShotWindows: [(UIWindow, String)] {
        let iPhoneXWindow = ScreenSize.iPhoneX.window
        let iPhone7Window = ScreenSize.iPhone7.window
        let iPadPro105Window = ScreenSize.iPadPro105.window
        
        return [
            (iPhoneXWindow, "iPhoneX"),
            (iPhone7Window, "iPhone7"),
            (iPadPro105Window, "iPadPro105")
        ]
    }
}
