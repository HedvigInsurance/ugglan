import Combine

extension Task {
    public func eraseToAnyCancellable() -> AnyCancellable {
        AnyCancellable(cancel)
    }
}
extension Task where Success == Never, Failure == Never {
    /// Runs `block`, then holds until at least `duration` has elapsed — on the throwing path too.
    public static nonisolated(nonsending) func withMinimumDuration<T>(
        _ duration: Duration,
        tolerance: Duration? = nil,
        _ block: () async throws -> T
    ) async rethrows -> T {
        let deadline = ContinuousClock.now.advanced(by: duration)
        do {
            let result = try await block()
            try? await Task.sleep(until: deadline, tolerance: tolerance)
            return result
        } catch {
            try? await Task.sleep(until: deadline, tolerance: tolerance)
            throw error
        }
    }
}
