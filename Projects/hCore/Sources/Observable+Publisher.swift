import Combine
import Observation

extension Observable where Self: AnyObject {
    /// A publisher for one property of an observable object, for watching it from outside a view.
    /// Combine supplies the operators Observation lacks, like `combineLatest`, `removeDuplicates`
    /// or `debounce`. Hold the subscription's `AnyCancellable`: releasing it stops the watch.
    ///
    /// It replays the current value on subscribe, as the old Combine-backed properties did, so a
    /// `dropFirst()` still means what it used to.
    @MainActor
    public func publisher<V>(for keyPath: KeyPath<Self, V>) -> AnyPublisher<V, Never> {
        let subject = CurrentValueSubject<V, Never>(self[keyPath: keyPath])
        let tracker = PropertyTracker { [weak self] in
            _ = self?[keyPath: keyPath]
        } onChange: { [weak self] in
            guard let self else { return }
            subject.send(self[keyPath: keyPath])
        }
        return
            subject
            .handleEvents(receiveCancel: { _ = tracker })
            .eraseToAnyPublisher()
    }
}

/// `withObservationTracking` fires once and then stops, so this arms itself again after every
/// change, for as long as it is held. `onChange` runs on the next main-actor turn rather than
/// inline, because observation reports a change before it is applied and the new value would
/// otherwise not be readable yet. Being a main-actor class is what lets the `@Sendable` change
/// handler capture it.
@MainActor
private final class PropertyTracker {
    private let read: @MainActor () -> Void
    private let onChange: @MainActor () -> Void

    init(read: @escaping @MainActor () -> Void, onChange: @escaping @MainActor () -> Void) {
        self.read = read
        self.onChange = onChange
        arm()
    }

    private func arm() {
        withObservationTracking { [weak self] in
            self?.read()
        } onChange: { [weak self] in
            Task { @MainActor in
                guard let self else { return }
                self.onChange()
                self.arm()
            }
        }
    }
}
