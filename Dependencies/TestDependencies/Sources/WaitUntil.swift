import Foundation
import Testing
import XCTest

/// Polls `closure` until it returns true, failing the test if `timeout` elapses first.
@MainActor
public func waitUntil(
    description: String,
    timeout: TimeInterval = 2,
    pollInterval: TimeInterval = 0.05,
    fileID: String = #fileID,
    file: StaticString = #filePath,
    line: UInt = #line,
    column: Int = #column,
    closure: @escaping () -> Bool
) async {
    let deadline = ContinuousClock.now.advanced(by: .seconds(timeout))

    while !closure() {
        guard !Task.isCancelled else { return }
        guard ContinuousClock.now < deadline else {
            // Test.current is non-nil only inside a Swift Testing test. XCTFail records nothing
            // when Testing is driving and Issue.record records nothing when XCTest is, so a
            // timeout has to be reported through whichever framework actually called this. Picking
            // wrong is silent: the wait returns, the test keeps going and passes on a condition
            // that never came true. Both branches stay until the last XCTest caller is migrated.
            // The location is built here rather than defaulted with #_sourceLocation, which expands at
            // the call site and so fails to compile in an XCTest file that does not import Testing.
            if Test.current != nil {
                Issue.record(
                    "timed out waiting for: \(description)",
                    sourceLocation: SourceLocation(
                        fileID: fileID,
                        filePath: "\(file)",
                        line: Int(line),
                        column: column
                    )
                )
            } else {
                XCTFail("timed out waiting for: \(description)", file: file, line: line)
            }
            return
        }
        try? await Task.sleep(nanoseconds: UInt64(pollInterval * 1_000_000_000))
    }
}

/// Runs `body` and records anything it throws as an issue instead of propagating it.
@MainActor
public func recordingErrors(
    sourceLocation: SourceLocation = #_sourceLocation,
    _ body: @MainActor () async throws -> Void
) async {
    do {
        try await body()
    } catch is ExpectationFailedError {
        // `#require` has already recorded its own failure before throwing this.
    } catch {
        Issue.record(error, sourceLocation: sourceLocation)
    }
}
