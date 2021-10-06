import Foundation
import UIKit

class FontBundleToken {}

public enum Fonts {
    private static let favoritStdBookFontName = "FavoritStd-Book"

    public static var favoritStdBook: UIFont = {
        let fontPath = Bundle(for: FontBundleToken.self).path(forResource: "FavoritStd-Book", ofType: "otf")
        let inData = NSData(contentsOfFile: fontPath!)
        let provider = CGDataProvider(data: inData!)

        let font = CGFont(provider!)
        var error: Unmanaged<CFError>?

        CTFontManagerRegisterGraphicsFont(font!, &error)
        error?.release()

        return UIFont(name: favoritStdBookFontName, size: UIFont.labelFontSize)!
    }()
    public static var forceTraitCollection: UITraitCollection? = nil

    public static func fontFor(style: UIFont.TextStyle) -> UIFont {
        let defaultDescriptor = UIFontDescriptor.preferredFontDescriptor(
            withTextStyle: style,
            compatibleWith: forceTraitCollection
        )
        let size = defaultDescriptor.pointSize
        let fontDescriptor = UIFontDescriptor(fontAttributes: [
            UIFontDescriptor.AttributeName.size: size,
            UIFontDescriptor.AttributeName.family: favoritStdBook.familyName,
        ])

        return UIFont(descriptor: fontDescriptor, size: size)
    }
}
