import Combine
import Observation

@MainActor
public final class ObservationWatcher {
    private let read: @MainActor () -> Void
    private let onChange: @MainActor () -> Void
    private var isCancelled = false

    /// Calls `onChange` whenever anything `read` touches changes, for as long as this object is held.
    ///
    /// `withObservationTracking` fires once and then stops, so a watcher that has to outlive a single
    /// change arms itself again after every one. `onChange` runs on the next main-actor turn rather
    /// than inline, because observation reports a change before it is applied and the new value would
    /// otherwise not be readable yet. Hold it like an `AnyCancellable`: releasing it stops the watch.
    public init(read: @escaping @MainActor () -> Void, onChange: @escaping @MainActor () -> Void) {
        self.read = read
        self.onChange = onChange
        arm()
    }

    public func cancel() {
        isCancelled = true
    }

    private func arm() {
        withObservationTracking { [weak self] in
            self?.read()
        } onChange: { [weak self] in
            Task { @MainActor in
                guard let self, !self.isCancelled else { return }
                self.onChange()
                self.arm()
            }
        }
    }
}

extension Observable where Self: AnyObject {
    /// A publisher for one property of an observable object, so an existing Combine chain can keep
    /// its operators. Observation has no `combineLatest`, `removeDuplicates` or `debounce`.
    ///
    /// It replays the current value on subscribe, as the old Combine-backed properties did, so a
    /// `dropFirst()` still means what it used to. The watcher lives as long as the pipeline.
    @MainActor
    public func publisher<V>(for keyPath: KeyPath<Self, V>) -> AnyPublisher<V, Never> {
        let subject = CurrentValueSubject<V, Never>(self[keyPath: keyPath])
        let watcher = ObservationWatcher { [weak self] in
            _ = self?[keyPath: keyPath]
        } onChange: { [weak self] in
            guard let self else { return }
            subject.send(self[keyPath: keyPath])
        }
        return
            subject
            .handleEvents(receiveCancel: { _ = watcher })
            .eraseToAnyPublisher()
    }
}
