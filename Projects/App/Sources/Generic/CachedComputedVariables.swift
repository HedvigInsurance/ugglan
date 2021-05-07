import Flow
import Foundation

class CachedComputedProperties {
	private let bag = DisposeBag()
	private var values: [String: Any]

	init(_ clearCacheSignal: Signal<Void>) {
		values = [:]

		bag += clearCacheSignal.with(weak: self).onValue { _, _ in self.values = [:] }
	}

	func compute<Value>(_ key: String, _ getValue: @escaping () -> Value) -> Value {
		if let cachedValueCast = values[key] as? Value?, let cachedValue = cachedValueCast {
			return cachedValue
		}

		let value = getValue()

		values[key] = value

		return value
	}
}
