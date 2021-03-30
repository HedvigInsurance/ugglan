import CoreDependencies
import Form
import Foundation
import Shake
import UIKit

public extension UIApplication {
    func setup() {
        DefaultStyling.installCustom()
        Shake.setup()
    }
}
