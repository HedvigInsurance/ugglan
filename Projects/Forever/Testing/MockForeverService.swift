import Flow
import Forever
import Foundation

public struct MockForeverService: ForeverService {
    let data: ForeverData
    public var dataSignal: ReadSignal<ForeverData?> {
        ReadSignal(data)
    }

    public func refetch() {}

    public init(data: ForeverData) {
        self.data = data
    }
}

public struct MockDelayedForeverService: ForeverService {
    let data: ForeverData
    let delay: TimeInterval
    public var dataSignal: ReadSignal<ForeverData?> {
        let signal = ReadWriteSignal<ForeverData?>(nil)

        let bag = DisposeBag()

        bag += Signal(after: delay).onValue {
            signal.value = self.data
        }

        return signal.hold(bag).readOnly()
    }

    public func refetch() {}

    public init(data: ForeverData, delay: TimeInterval) {
        self.data = data
        self.delay = delay
    }
}
