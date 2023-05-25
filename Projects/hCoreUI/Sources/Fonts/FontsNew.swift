import SwiftUI
import hAnalytics

class FontBundleTokenNew {}

public enum FontsNew {
    private static let favoritStdBookFontName = "FavoritStd-Book"
    private static let hedvigLettersStandardFontName = "HedvigLetters-Standard"
    private static let hedvigLettersSmallFontName = "HedvigLetters-Small"

    private static func loadFontNew(resourceName: String) -> UIFont {
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

    public static var hedvigLettersStandardNew: UIFont = {
        loadFontNew(resourceName: hedvigLettersStandardFontName)
    }()

    public static var hedvigLettersSmallNew: UIFont = {
        loadFontNew(resourceName: hedvigLettersSmallFontName)
    }()

    public static var favoritStdBookNew: UIFont = {
        loadFontNew(resourceName: favoritStdBookFontName)
    }()

    public static var forceTraitCollectionNew: UITraitCollection? = nil

    public static func fontForNew(style: HFontTextStyleNew) -> UIFont {
        func getFontNew(_ font: UIFont) -> UIFont {

            let defaultDescriptor = UIFontDescriptor(
                name: style.uifontTextStyleNew.fontName,
                size: style.uifontTextStyleNew.pointSize
            )
            let size = defaultDescriptor.pointSize
            let fontDescriptor = UIFontDescriptor(fontAttributes: [
                UIFontDescriptor.AttributeName.size: size,
                UIFontDescriptor.AttributeName.family: font.familyName,
                UIFontDescriptor.AttributeName.name: font.fontName,
            ])

            return UIFont(descriptor: fontDescriptor, size: size)
        }

        if !hAnalyticsExperiment.useHedvigLettersFont {
            return getFontNew(favoritStdBookNew)
        }

        switch style {
        case .title2:
            return getFont(hedvigLettersSmall)
        default:
            return getFontNew(hedvigLettersStandardNew)
        }
    }
}
