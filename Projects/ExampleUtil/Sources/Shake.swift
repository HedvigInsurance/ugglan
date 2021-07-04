import CoreDependencies
import Form
import Foundation
import UIKit

#if canImport(Shake)
	import Shake
#endif

extension UIApplication {
	public func setup() {
		DefaultStyling.installCustom()
		#if canImport(Shake)
			Shake.setup()
		#endif
	}
}
