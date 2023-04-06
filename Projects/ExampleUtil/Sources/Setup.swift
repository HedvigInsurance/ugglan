import CoreDependencies
import Form
import Foundation
import UIKit
import hCore

extension UIApplication {
    public func setup() {
        DefaultStyling.installCustom()
        Localization.Locale.currentLocale = .en_SE
    }
}
