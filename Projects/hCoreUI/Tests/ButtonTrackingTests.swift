//
//  ButtonTrackingTests.swift
//  hCoreTests
//
//  Created by sam on 8.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import hCore
@testable import hCoreUI
import Testing
import UIKit
import XCTest

final class ButtonTrackingTests: XCTestCase {
    func test() {
        let buttonTrackingHandlerExpectation = expectation(description: "Button.trackingHandler to be called")

        Button.trackingHandler = { _ in
            buttonTrackingHandlerExpectation.fulfill()
        }

        let button = Button(title: "mock", type: .standard(backgroundColor: .black, textColor: .black))

        let (buttonView, buttonBag) = button.materialize(events: ViewableEvents(wasAddedCallbacker: .init()))

        let bag = DisposeBag()

        bag += buttonBag

        buttonView.sendActions(for: .touchUpInside)

        wait(for: [buttonTrackingHandlerExpectation], timeout: 2)

        bag.dispose()
    }
}
