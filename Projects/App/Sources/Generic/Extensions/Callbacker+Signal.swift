import Flow
import Foundation

extension Callbacker {
    /// Returns a new singal from self
    func signal() -> CoreSignal<Plain, Value> { Signal(callbacker: self) }
}
