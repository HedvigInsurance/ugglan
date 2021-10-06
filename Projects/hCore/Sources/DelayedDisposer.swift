import Flow
import Foundation

public struct DelayedDisposer: Disposable {
    let disposable: Disposable
    let delay: TimeInterval
    private let onDisposeCallbacker: Callbacker<Void>
    let onDisposeSignal: Signal<Void>
    let bag: DisposeBag

    public func dispose() {
        bag += Signal(after: delay)
            .onValue { () in self.bag.dispose()
                self.disposable.dispose()
            }
    }

    public init(
        _ disposable: Disposable,
        delay: TimeInterval
    ) {
        onDisposeCallbacker = Callbacker<Void>()
        onDisposeSignal = onDisposeCallbacker.providedSignal
        bag = DisposeBag()
        self.delay = delay
        self.disposable = disposable
    }
}
