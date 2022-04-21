import Flow
import XCTest

@testable import hCore

class FiniteSignal_TakeUntil: XCTestCase {

    func testExample() throws {
        var array = [10]
        var terminate = [false]

        let bag = DisposeBag()
        let expectation = self.expectation(description: "Signal sent sequence")

        let terminateSignal = terminate.signal().plain().readable(initial: false)
        let newSignal = array.signal().take(until: terminateSignal)

        terminate.append(true)

        array.append(20)

        bag += newSignal.onValue { value in
            XCTAssertEqual(value, 10)
        }

        bag += array.signal()
            .onValue { value in
                if value == 20 {
                    expectation.fulfill()
                }
            }

        waitForExpectations(timeout: 10) { _ in
            bag.dispose()
        }
    }
}
