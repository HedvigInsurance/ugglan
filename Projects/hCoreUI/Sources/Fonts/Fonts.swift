import Foundation
import UIKit
import hAnalytics

class FontBundleToken {}

public enum Fonts {
    private static let favoritStdBookFontName = "FavoritStd-Book"
    private static let hedvigLettersStandardFontName = "HedvigLetters-Standard"
    private static let hedvigLettersSmallFontName = "HedvigLetters-Small"
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

    public static var hedvigLettersStandard: UIFont = {
        loadFont(resourceName: hedvigLettersStandardFontName)
    }()

    public static var hedvigLettersSmall: UIFont = {
        loadFont(resourceName: hedvigLettersSmallFontName)
    }()

    public static var hedvigLettersBig: UIFont = {
        loadFont(resourceName: hedvigLettersBigFontName)
    }()

    public static var favoritStdBook: UIFont = {
        loadFont(resourceName: favoritStdBookFontName)
    }()

    public static var forceTraitCollection: UITraitCollection? = nil

    public static func fontFor(style: HFontTextStyle) -> UIFont {
        func getFont(_ font: UIFont) -> UIFont {
            let size = style.fontSize * style.multiplier
            let fontDescriptor = UIFontDescriptor(fontAttributes: [
                UIFontDescriptor.AttributeName.size: size,
                UIFontDescriptor.AttributeName.family: font.familyName,
                UIFontDescriptor.AttributeName.name: font.fontName,
            ])

            return UIFont(descriptor: fontDescriptor, size: size)
        }

        switch style {
        case .title1, .title:
            return getFont(hedvigLettersBig)
        default:
            return getFont(hedvigLettersStandard)
        }
    }
}
