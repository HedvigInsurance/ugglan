import Flow
import Foundation
@testable import hCore
import XCTest

final class ViewableTests: XCTestCase {
    func testViewable() {
        struct TestViewable: Viewable {
            func materialize(events _: ViewableEvents) -> (String, Future<String>) {
                return ("mock", Future { _ in
                    NilDisposer()
                })
            }
        }

        let (result, _) = TestViewable().materialize(
            events: ViewableEvents(wasAddedCallbacker: Callbacker<Void>())
        )

        XCTAssert(result == "mock")
    }
}
