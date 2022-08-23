import Flow
import Foundation
import SwiftUI
import UIKit
import hCore

extension Color {
    func uiColor() -> UIColor {
        if #available(iOS 14.0, *) {
            return UIColor(self)
        }

        let components = self.components()
        return UIColor(red: components.r, green: components.g, blue: components.b, alpha: components.a)
    }

    private func components() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        let scanner = Scanner(string: self.description.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var hexNumber: UInt64 = 0
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0

        let result = scanner.scanHexInt64(&hexNumber)
        if result {
            r = CGFloat((hexNumber & 0xff00_0000) >> 24) / 255
            g = CGFloat((hexNumber & 0x00ff_0000) >> 16) / 255
            b = CGFloat((hexNumber & 0x0000_ff00) >> 8) / 255
            a = CGFloat(hexNumber & 0x0000_00ff) / 255
        }
        return (r, g, b, a)
    }
}
