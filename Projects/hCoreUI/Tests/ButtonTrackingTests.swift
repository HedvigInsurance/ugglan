import Flow
import Foundation
import Testing
import UIKit
import XCTest
import hCore

@testable import hCoreUI

final class ButtonTrackingTests: XCTestCase {
    func test() {
        let buttonTrackingHandlerExpectation = expectation(description: "AnalyticsSender.sendEvent to be called")

        AnalyticsSender.sendEvent = { name, properties in
            if name == "BUTTON_CLICK" {
                XCTAssertEqual("ABOUT_LANGUAGE_ROW", properties["localizationKey"] as? String)
                buttonTrackingHandlerExpectation.fulfill()
            }
        }

        let button = Button(title: L10n.aboutLanguageRow, type: .standard(backgroundColor: .black, textColor: .black))

        let (buttonView, buttonBag) = button.materialize(events: ViewableEvents(wasAddedCallbacker: .init()))

        let bag = DisposeBag()

        bag += buttonBag

        buttonView.sendActions(for: .touchUpInside)

        wait(for: [buttonTrackingHandlerExpectation], timeout: 2)

        bag.dispose()
    }
}
