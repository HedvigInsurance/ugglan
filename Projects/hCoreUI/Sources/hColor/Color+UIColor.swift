import Foundation
import SwiftUI

extension Color {
    public func uiColor() -> UIColor {
        UIColor(self)
    }
}

extension hColor {
    /// Resolves the color into a light/dark adaptive `UIColor` at the `.base` interface level.
    public func uiColor() -> UIColor {
        UIColor(
            light: colorFor(.light, .base).color.uiColor(),
            dark: colorFor(.dark, .base).color.uiColor()
        )
    }
}
