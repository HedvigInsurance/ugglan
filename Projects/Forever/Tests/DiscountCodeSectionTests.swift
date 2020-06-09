//
//  DiscountCodeSectionTests.swift
//  ForeverTests
//
//  Created by sam on 9.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import hCoreUI
import SnapshotTesting
import Testing
import XCTest
@testable import Forever

final class DiscountCodeSectionTests: XCTestCase {
    override func setUp() {
        super.setUp()
        setupScreenShotTests()
        DefaultStyling.installCustom()
    }
    
    func testScreenshot() {
        let discountCodeSection = DiscountCodeSection()
        
        materializeViewable(discountCodeSection) { view in
            view.snp.makeConstraints { make in
                make.width.equalTo(300)
            }
            
            assertSnapshot(matching: view, as: .image)
        }
    }
}
