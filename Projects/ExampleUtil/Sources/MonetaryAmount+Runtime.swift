import Foundation
import Runtime
import hCore
import hGraphQL

extension MonetaryAmount: DefaultConstructor {
    public init() { self = MonetaryAmount(amount: "10.0", currency: "SEK") }
}
