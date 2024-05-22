import CoreDependencies
import Foundation
import SwiftUI
import hCore

extension UIApplication {
    public func setup() {
        Localization.Locale.currentLocale.value = .en_SE
    }
}
