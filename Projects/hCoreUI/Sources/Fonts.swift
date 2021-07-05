import Foundation
import SwiftUI
import UIKit

class FontBundleToken {}

public enum Fonts {
	fileprivate static let favoritStdBookFontName = "FavoritStd-Book"

	public static var favoritStdBook: UIFont = {
		let fontPath = Bundle(for: FontBundleToken.self).path(forResource: "FavoritStd-Book", ofType: "otf")
		let inData = NSData(contentsOfFile: fontPath!)
		let provider = CGDataProvider(data: inData!)

		let font = CGFont(provider!)
		var error: Unmanaged<CFError>?
		CTFontManagerRegisterGraphicsFont(font!, &error)

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
	@available(iOS 13, *) public static var font: Font { Font(favoritStdBook) }
}
