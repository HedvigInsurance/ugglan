import Flow
import Foundation

extension ReadWriteSignal {
	static func `static`<Value>(_ value: Value) -> ReadWriteSignal<Value> { ReadWriteSignal(value) }
}
