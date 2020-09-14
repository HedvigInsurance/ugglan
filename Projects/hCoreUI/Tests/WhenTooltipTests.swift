//
//  WhenTooltipTests.swift
//  hCoreUI
//
//  Created by sam on 14.9.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import hCore
@testable import hCoreUI
import Testing
import UIKit
import XCTest

final class WhenTooltipTests: XCTestCase {
    func test() {
        let whenTooltip = WhenTooltip(when: .onceEvery(timeInterval: 40), tooltip: .init(id: "mock", value: "mock", sourceRect: .zero))
        whenTooltip.reset()

        let bag = DisposeBag()
        let view = UIView()
        bag += view.present(whenTooltip)

        XCTAssertEqual(view.subviews.count, 1)

        let anotherView = UIView()
        bag += anotherView.present(whenTooltip)

        XCTAssertEqual(anotherView.subviews.count, 0)
    }
}
