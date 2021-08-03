import Foundation
import SwiftUI
import UIKit

public struct hText: View {
	let text: String
	let style: UIFont.TextStyle

	public init(
		text: String,
		style: UIFont.TextStyle
	) {
		self.text = text
		self.style = style
	}

	public var body: some View {
		Text(text)
			.font(Font(Fonts.fontFor(style: style)))
	}
}
