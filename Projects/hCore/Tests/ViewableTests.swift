import Foundation
import XCTest
import Core
import Flow

final class ViewableTests: XCTestCase {
    func testViewable() {
        struct TestViewable: Viewable {
            func materialize(events: ViewableEvents) -> (String, Future<String>) {
                return ("mock", Future { _ in
                    return NilDisposer()
                })
            }
        }
        
        let (result, _) = TestViewable().materialize(
            events: ViewableEvents(wasAddedCallbacker: Callbacker<Void>())
        )
        
        XCTAssert(result == "mock")
    }

}
