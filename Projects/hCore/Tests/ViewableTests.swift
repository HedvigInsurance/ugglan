import Flow
import Foundation
import XCTest

@testable import hCore

final class ViewableTests: XCTestCase {
    func testViewable() {
        struct TestViewable: Viewable {
            func materialize(events _: ViewableEvents) -> (String, Future<String>) {
                ("mock", Future { _ in NilDisposer() })
            }
        }

        let (result, _) = TestViewable()
            .materialize(events: ViewableEvents(wasAddedCallbacker: Callbacker<Void>()))

        XCTAssert(result == "mock")
    }
}
