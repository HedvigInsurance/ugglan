import Combine

extension Task {
    public func eraseToAnyCancellable() -> AnyCancellable {
        AnyCancellable(cancel)
    }
}
