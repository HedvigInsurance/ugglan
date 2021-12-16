import Flow
import Foundation

extension Future {
    /// calls on value on the future, and never notifies you, effectively swallowing its value
    @discardableResult public func sink() -> Future<Value> {
        self.onValue { _ in }
    }
}
