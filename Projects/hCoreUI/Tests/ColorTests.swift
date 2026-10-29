import Foundation
import SwiftUI
import Testing
import UIKit

@testable import hCoreUI

@MainActor
final class ColorTests {
    @Test
    func hedvigColors() {
        let background = UIColor.brand(.primaryBackground())
        let light = background.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
        let dark = background.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))

        // grayScale25 (#FAFAFA) in light mode, grayScale1000 (#121212) in dark mode
        #expect(light.hasGray(250))
        #expect(dark.hasGray(18))

        // An explicit style wins over the trait collection
        let forcedDark = UIColor.brand(.primaryBackground(), style: .dark)
        #expect(forcedDark.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light)).hasGray(18))
    }

    @Test
    func dynamicPolyfill() {
        let color = UIColor { trait -> UIColor in trait.userInterfaceStyle == .dark ? .black : .white }

        #expect(
            color.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark)).cgColor
                == UIColor.black.cgColor
        )
        #expect(
            color.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light)).cgColor
                == UIColor.white.cgColor
        )
    }
}

extension UIColor {
    /// Whether red, green and blue all equal `value` on a 0-255 scale, within rounding
    fileprivate func hasGray(_ value: CGFloat) -> Bool {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        guard getRed(&red, green: &green, blue: &blue, alpha: nil) else { return false }
        return [red, green, blue].allSatisfy { abs($0 * 255 - value) < 1 }
    }
}
