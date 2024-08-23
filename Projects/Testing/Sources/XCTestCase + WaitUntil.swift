//import XCTest
//
//extension XCTestCase {
//    public func waitUntil(description: String, closure: @escaping () -> Bool) async {
//        let exc = expectation(description: description)
//        if closure() {
//            exc.fulfill()
//        } else {
//            try! await Task.sleep(nanoseconds: 100_000_000)
//            Task {
//                await self.waitUntil(description: description, closure: closure)
//                if closure() {
//                    exc.fulfill()
//                }
//            }
//        }
//        await fulfillment(of: [exc], timeout: 2)
//    }
//}
