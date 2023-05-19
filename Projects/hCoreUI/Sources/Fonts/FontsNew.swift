import SwiftUI
//import Foundation
//import UIKit
import hAnalytics

class FontBundleTokenNew {}

public enum FontsNew {
    private static let favoritStdBookFontName = "FavoritStd-Book"
    private static let hedvigLettersStandardFontName = "HedvigLetters-Standard"
    private static let hedvigLettersSmallFontName = "HedvigLetters-Small"

    private static func loadFontNew(resourceName: String) -> Font {
        let fontPath = Bundle(for: FontBundleToken.self).path(forResource: resourceName, ofType: "otf")
        let inData = NSData(contentsOfFile: fontPath!)
        let provider = CGDataProvider(data: inData!)

        let font = CGFont(provider!)
        var error: Unmanaged<CFError>?

        CTFontManagerRegisterGraphicsFont(font!, &error)
        error?.release()

        let fontName = font?.postScriptName as String?
        //        return Font(CTFont.init(fontName, size: 23))
        //        return UIFont(name: fontName!, size: UIFont.labelFontSize)!
        return Font(CTFont(CTFontUIFontType.label, size: 24)) /* TODO: CHANGE */
    }

    public static var hedvigLettersStandardNew: Font = {
        loadFontNew(resourceName: hedvigLettersStandardFontName)
    }()

    public static var hedvigLettersSmallNew: Font = {
        loadFontNew(resourceName: hedvigLettersSmallFontName)
    }()

    public static var favoritStdBookNew: Font = {
        loadFontNew(resourceName: favoritStdBookFontName)
    }()

    public static var forceTraitCollectionNew: UITraitCollection? = nil

    public static func fontForNew(style: HFontTextStyleNew) -> Font {
        func getFontNew(_ font: Font) -> Font {
            ////            let defaultDescriptor = UIFontDescriptor.preferredFontDescriptor(
            ////                withTextStyle: style.uifontTextStyleNew,
            ////                compatibleWith: forceTraitCollectionNew
            ////            )
            ////            let size = defaultDescriptor.pointSize
            //        let fontDescriptor = CTFontDescriptor(fontAttr)
            //            let fontDescriptor = UIFontDescriptor(fontAttributes: [
            ////                UIFontDescriptor.AttributeName.size: size,
            ////                UIFontDescriptor.AttributeName.family: font.familyName,
            ////                UIFontDescriptor.AttributeName.name: font.fontName,
            //            ])

            //            return UIFont(descriptor: fontDescriptor, size: size)
            //            return Font(CTFont(CTFontDescriptor(font), size: 24))
            return Font(CTFont(.controlContent, size: 24)) /* TODO: CHANGE */
        }

        if !hAnalyticsExperiment.useHedvigLettersFont {
            return getFontNew(favoritStdBookNew)
        }

        switch style {
        ////        case .prominentTitle:
        ////            return getFontNew(hedvigLettersSmallNew)
        default:
            return getFontNew(hedvigLettersStandardNew)
        }
    }
}
