import Foundation
import Shake
import UIKit

extension Shake {
	public static func setup() {
		Shake.configuration.isInvokedByScreenshot = true
		Shake.start(
			clientId: "UL4cR8O6F49Vac5LzphITIEMDi1bp6GhbaE0Cj1O",
			clientSecret: "f3QstvAkEEsnKtzLc5RthSF83qklzmb4J5S6ICqUBEBxHeyEuGBO1o9"
		)
	}
}
