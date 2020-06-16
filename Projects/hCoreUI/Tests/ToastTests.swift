//
//  ToastTests.swift
//  hCoreUITests
//
//  Created by sam on 8.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
@testable import hCoreUI
import SnapshotTesting
import Testing
import XCTest

final class ToastTests: XCTestCase {
    override func setUp() {
        super.setUp()
        setupScreenShotTests()
        DefaultStyling.installCustom()
    }

    func test() {
        let toast = Toast(value: "Testing a title!")

        materializeViewable(toast) { view in
            view.snp.makeConstraints { make in
                make.width.equalTo(400)
            }

            assertSnapshot(matching: view, as: .image)
        }
    }
}
