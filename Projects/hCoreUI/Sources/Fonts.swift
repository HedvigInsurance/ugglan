import Foundation
import UIKit
import hAnalytics

class FontBundleToken {}

public enum Fonts {
    private static let favoritStdBookFontName = "FavoritStd-Book"
    private static let hedvigLettersStandardFontName = "HedvigLetters-Standard"
    private static let hedvigLettersSmallFontName = "HedvigLetters-Small"
    
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
    
    public static var favoritStdBook: UIFont = {
        loadFont(resourceName: favoritStdBookFontName)
    }()
    
    public static var forceTraitCollection: UITraitCollection? = nil

    public static func fontFor(style: UIFont.TextStyle) -> UIFont {
        func getFont(_ font: UIFont) -> UIFont {
            let defaultDescriptor = UIFontDescriptor.preferredFontDescriptor(
                withTextStyle: style,
                compatibleWith: forceTraitCollection
            )
            let size = defaultDescriptor.pointSize
            let fontDescriptor = UIFontDescriptor(fontAttributes: [
                UIFontDescriptor.AttributeName.size: size,
                UIFontDescriptor.AttributeName.family: font.familyName,
                UIFontDescriptor.AttributeName.name: font.fontName,
            ])

            return UIFont(descriptor: fontDescriptor, size: size)
        }
        
        if (hAnalyticsExperiment.useHedvigLettersFont) {
            return getFont(favoritStdBook)
        }
        
        switch style {
        case .largeTitle, .title1:
            return getFont(hedvigLettersSmall)
        default:
            return getFont(hedvigLettersStandard)
        }
    }
}
