#if canImport(Adyen)

import Adyen
import Foundation

struct AdyenOptions {
	let paymentMethods: PaymentMethods
	let clientEncrytionKey: String
}

#endif
