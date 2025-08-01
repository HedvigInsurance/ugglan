import Flow
import Forever
import Foundation

public struct MockForeverService: ForeverService {
    public func changeDiscountCode(_ value: String) -> Signal<Either<Void, ForeverChangeCodeError>> {
        Signal(after: 0)
            .atValue {
                var data = _dataSignal.value
                data?.updateDiscountCode(value)
                _dataSignal.value = data
            }
            .map { .left(()) }
    }

    var _dataSignal = ReadWriteSignal<ForeverData?>(nil)
    public var dataSignal: ReadSignal<ForeverData?> { _dataSignal.readOnly() }

    public func refetch() {}

    public init(data: ForeverData) { _dataSignal.value = data }
}

public class MockDelayedForeverService: ForeverService {
    public func changeDiscountCode(_ value: String) -> Signal<Either<Void, ForeverChangeCodeError>> {
        Signal(after: 0.5)
            .atValue {
                var data = self._dataSignal.value
                data?.updateDiscountCode(value)
                self._dataSignal.value = data
            }
            .map { .left(()) }
    }

    var _dataSignal = ReadWriteSignal<ForeverData?>(nil)
    let delay: TimeInterval
    public var dataSignal: ReadSignal<ForeverData?> { _dataSignal.readOnly() }

    public func refetch() {}

    func timer(data: ForeverData) {
        let bag = DisposeBag()
        bag += Signal(after: delay)
            .onValue {
                self._dataSignal.value = data
                bag.dispose()
            }
    }

    public init(
        data: ForeverData,
        delay: TimeInterval
    ) {
        self.delay = delay
        timer(data: data)
    }
}
