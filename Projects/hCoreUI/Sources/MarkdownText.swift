import Flow
import Form
import Foundation
import hCore
import MarkdownKit
import UIKit

public struct MarkdownText {
	public let textSignal: ReadWriteSignal<String>
	public let style: TextStyle

	public init(
		textSignal: ReadWriteSignal<String>,
		style: TextStyle
	) {
		self.textSignal = textSignal
		self.style = style
	}

	public init(
		value: String,
		style: TextStyle
	) {
		textSignal = ReadWriteSignal(value)
		self.style = style
	}
}

extension MarkdownText: Viewable {
	public func materialize(events _: ViewableEvents) -> (UILabel, Disposable) {
		let bag = DisposeBag()

		let markdownParser = MarkdownParser(font: style.font, color: style.color)

		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineSpacing = style.lineSpacing
		paragraphStyle.alignment = style.alignment
		paragraphStyle.lineSpacing = 3

		let markdownText = UILabel()
		markdownText.numberOfLines = 0
		markdownText.lineBreakMode = .byWordWrapping
		markdownText.baselineAdjustment = .none

		bag += textSignal.atOnce()
			.onValue { text in let attributedString = markdownParser.parse(text)

				if !text.isEmpty {
					let mutableAttributedString = NSMutableAttributedString(
						attributedString: attributedString
					)
					mutableAttributedString.addAttribute(
						.paragraphStyle,
						value: paragraphStyle,
						range: NSRange(location: 0, length: mutableAttributedString.length - 1)
					)

					markdownText.attributedText = mutableAttributedString
				}
			}

		bag += markdownText.didLayoutSignal.onValue { _ in
			markdownText.preferredMaxLayoutWidth = markdownText.frame.size.width
		}

		return (markdownText, bag)
	}
}
