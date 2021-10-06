import Flow
import Foundation

extension CoreSignal {
    /// returns a signal that maps current signal to a readable signal with an initial value of false, maps to true after first value
    public func boolean() -> CoreSignal<Read, Bool> { map { _ in true }.plain().readable(initial: false) }
}
