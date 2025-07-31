import Foundation
import SwiftUI

class FontBundleToken {}

@MainActor
public enum Fonts {
    private static let hedvigLettersStandardFontName = "HedvigLetters-Standard"
    private static let hedvigLettersBigFontName = "HedvigLetters-Big"

    private static func loadFont(resourceName: String) -> UIFont {
        let fontPath = Bundle(for: FontBundleToken.self).path(forResource: resourceName, ofType: "otf")
        let inData = NSData(contentsOfFile: fontPath!)
        let provider = CGDataProvider(data: inData!)

        let font = CGFont(provider!)
        var error: Unmanaged<CFError>?

        CTFontManagerRegisterGraphicsFont(font!, &error)
        error?.release()

        let fontName = font?.postScriptName as String?
        return UIFont(name: fontName!, size: UIFont.labelFontSize)!
    }

    public static var hedvigLettersStandard: UIFont = loadFont(resourceName: hedvigLettersStandardFontName)

    public static var hedvigLettersBig: UIFont = loadFont(resourceName: hedvigLettersBigFontName)

    public static var forceTraitCollection: UITraitCollection?

    public static func fontFor(style: HFontTextStyle, withoutFontMultipler: Bool = false) -> UIFont {
        func getFont(_ font: UIFont) -> UIFont {
            let size = style.fontSize * (withoutFontMultipler ? 1 : style.multiplier)
            let fontDescriptor = UIFontDescriptor(fontAttributes: [
                UIFontDescriptor.AttributeName.size: size,
                UIFontDescriptor.AttributeName.family: font.familyName,
                UIFontDescriptor.AttributeName.name: font.fontName,
            ])

            return UIFont(descriptor: fontDescriptor, size: size)
        }

        switch style {
        case .displayXXLShort, .displayXXLLong, .displayXLShort, .displayXLLong, .displayLShort, .displayLLong,
            .displayMShort, .displayMLong, .displaySShort, .displaySLong, .displayXSShort, .displayXSLong:
            return getFont(hedvigLettersBig)
        default:
            return getFont(hedvigLettersStandard)
        }
    }
}

@MainActor
private struct EnvironmentWithoutFontMultiplier: @preconcurrency EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    public var hWithoutFontMultiplier: Bool {
        get { self[EnvironmentWithoutFontMultiplier.self] }
        set { self[EnvironmentWithoutFontMultiplier.self] = newValue }
    }
}

extension View {
    public var hWithoutFontMultiplier: some View {
        environment(\.hWithoutFontMultiplier, true)
    }
}
