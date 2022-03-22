import Form
import Foundation
import UIKit
import hCore
import hCoreUI

extension UIApplication {
    public func setup() {
        DefaultStyling.installCustom()
        Localization.Locale.currentLocale = .en_SE
    }
}
