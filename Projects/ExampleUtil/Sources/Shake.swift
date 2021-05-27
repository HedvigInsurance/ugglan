import CoreDependencies
import Form
import Foundation
import Shake
import UIKit

extension UIApplication {
	public func setup() {
		DefaultStyling.installCustom()
		Shake.setup()
	}
}
