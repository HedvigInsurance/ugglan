import Flow
import Form
import Foundation
import MarkdownKit
import UIKit
import hCore

public struct MarkdownTextView {
	public let textSignal: ReadWriteSignal<String>
	public let style: TextStyle
	public let linkColor: UIColor

	public init(
		textSignal: ReadWriteSignal<String>,
		style: TextStyle,
		linkColor: UIColor
	) {
		self.textSignal = textSignal
		self.style = style
		self.linkColor = linkColor
	}

	public init(
		value: String,
		style: TextStyle,
		linkColor: UIColor
	) {
		textSignal = ReadWriteSignal(value)
		self.style = style
		self.linkColor = linkColor
	}
}

extension MarkdownTextView: Viewable {
	public func materialize(events _: ViewableEvents) -> (UITextView, Disposable) {
		let bag = DisposeBag()

		let markdownParser = MarkdownParser(font: style.font, color: style.color)

		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineSpacing = style.lineSpacing
		paragraphStyle.alignment = style.alignment
		paragraphStyle.lineSpacing = 3

		let markdownTextView = UITextView()
		markdownTextView.isEditable = false
		markdownTextView.isUserInteractionEnabled = true
		markdownTextView.isScrollEnabled = false
		markdownTextView.backgroundColor = .clear
		markdownTextView.linkTextAttributes = [.foregroundColor: linkColor]

		bag += textSignal.atOnce()
			.onValue { text in let attributedString = markdownParser.parse(text)

				if !text.isEmpty {
					let mutableAttributedString = NSMutableAttributedString(
						attributedString: attributedString
					)
					mutableAttributedString.addAttribute(
						.paragraphStyle,
						value: paragraphStyle,
						range: NSMakeRange(0, mutableAttributedString.length - 1)
					)

					markdownTextView.attributedText = mutableAttributedString
				}
			}

		return (markdownTextView, bag)
	}
}
