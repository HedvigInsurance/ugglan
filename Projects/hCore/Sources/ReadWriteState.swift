import Flow
import Foundation

@propertyWrapper public struct ReadWriteState<T> {
    var signal: ReadWriteSignal<T>
    public var projectedValue: ReadWriteSignal<T> { signal }
    public var wrappedValue: T {
        get { signal.value }
        set { signal.value = newValue }
    }

    public init(wrappedValue value: T) { signal = ReadWriteSignal(value) }

    public init(wrappedValue value: ReadWriteSignal<T>) { signal = value }
}
