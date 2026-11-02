import Foundation
import Testing

/// Polls `closure` until it returns true, failing the test if `timeout` elapses first.
@MainActor
public func waitUntil(
    description: String,
    timeout: TimeInterval = 2,
    pollInterval: TimeInterval = 0.05,
    sourceLocation: SourceLocation = #_sourceLocation,
    closure: () -> Bool
) async {
    let deadline = ContinuousClock.now.advanced(by: .seconds(timeout))

    while !closure() {
        guard !Task.isCancelled else {
            Issue.record("waitUntil cancelled: \(description)", sourceLocation: sourceLocation)
            return
        }
        guard ContinuousClock.now < deadline else {
            Issue.record("timed out waiting for: \(description)", sourceLocation: sourceLocation)
            return
        }
        try? await Task.sleep(for: .seconds(pollInterval))
    }
}

/// Runs `body` and records anything it throws as a Swift Testing issue instead of propagating it.
/// Swift Testing only: `Issue.record` is not reported when called from an XCTest test.
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
