//
//  TooltipTests.swift
//  hCoreUITests
//
//  Created by sam on 15.9.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import hCore
@testable import hCoreUI
import SnapshotTesting
import Testing
import UIKit
import XCTest

final class TooltipTests: XCTestCase {
    override func setUp() {
        super.setUp()
        setupScreenShotTests()
    }

    func testScreenshot() {
        let tooltip = Tooltip(id: "mock", value: "mock", sourceRect: .zero)

        let viewController = UIViewController()

        let bag = DisposeBag()
        let view = UIView()
        viewController.view.addSubview(view)
        bag += view.present(tooltip)

        view.snp.makeConstraints { make in
            make.width.equalTo(2)
            make.height.equalTo(2)
            make.top.right.equalToSuperview()
        }

        assertSnapshot(matching: viewController, as: .image)
    }
}
