import Foundation
import XCTest

/// Polls `closure` until it returns true, failing the test if `timeout` elapses first.
@MainActor
public func waitUntil(
    description: String,
    timeout: TimeInterval = 2,
    pollInterval: TimeInterval = 0.05,
    file: StaticString = #filePath,
    line: UInt = #line,
    closure: @escaping () -> Bool
) async {
    let deadline = ContinuousClock.now.advanced(by: .seconds(timeout))

    while !closure() {
        guard !Task.isCancelled else { return }
        guard ContinuousClock.now < deadline else {
            return XCTFail("timed out waiting for: \(description)", file: file, line: line)
        }
        try? await Task.sleep(nanoseconds: UInt64(pollInterval * 1_000_000_000))
    }
}
