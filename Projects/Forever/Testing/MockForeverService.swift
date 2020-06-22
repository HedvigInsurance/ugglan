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

public class MockDelayedForeverService: ForeverService {
    var _dataSignal = ReadWriteSignal<ForeverData?>(nil)
    let delay: TimeInterval
    public var dataSignal: ReadSignal<ForeverData?> {
        _dataSignal.readOnly()
    }

    public func refetch() {}
    
    func timer(data: ForeverData) {
        let bag = DisposeBag()
        bag += Signal(after: delay).onValue {
            self._dataSignal.value = data
          bag.dispose()
        }
    }

    public init(data: ForeverData, delay: TimeInterval) {
        self.delay = delay
        timer(data: data)
    }
}
