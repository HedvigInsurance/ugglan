import Foundation
import hCore
import Runtime

extension MonetaryAmount: DefaultConstructor {
	public init() { self = MonetaryAmount(amount: "10.0", currency: "SEK") }
}
