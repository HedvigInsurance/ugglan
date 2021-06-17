import CoreDependencies
import Form
import Foundation
import Shake
import UIKit
import hCore

extension UIApplication {
	public func setup() {
		DefaultStyling.installCustom()
		Shake.setup()
        Localization.Locale.currentLocale = .en_SE
	}
}
