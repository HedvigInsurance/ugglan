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
    func testDoesntShowAgain() {
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

    func testShowsAfterTimeIntervalHasPassed() {
        let tooltip = Tooltip(id: "mock", value: "mock", sourceRect: .zero)
        let when = WhenTooltip.When.onceEvery(timeInterval: 40)
        let whenTooltip = WhenTooltip(when: when, tooltip: tooltip)
        whenTooltip.reset()

        let bag = DisposeBag()
        let view = UIView()
        bag += view.present(whenTooltip)

        XCTAssertEqual(view.subviews.count, 1)

        struct MockDateProvider: DateProvider {
            var date: Date {
                Date().addingTimeInterval(60)
            }
        }

        let anotherView = UIView()
        bag += anotherView.present(WhenTooltip(when: when, tooltip: tooltip, dateProvider: MockDateProvider()))

        XCTAssertEqual(anotherView.subviews.count, 1)
    }
}
