import Combine

extension Task {
    public func eraseToAnyCancellable() -> AnyCancellable {
        AnyCancellable(cancel)
    }
}
extension Task where Success == Never, Failure == Never {
    public static func sleep(seconds: Float) async throws {
        let nanoseconds = UInt64(seconds * 1_000_000_000)
        try await Task.sleep(nanoseconds: nanoseconds)
    }
}
