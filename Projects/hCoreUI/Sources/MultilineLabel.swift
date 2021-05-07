import Flow
import Form
import Foundation
import UIKit
import hCore

public struct MultilineLabel {
	@ReadWriteState public var value: DisplayableString
	@ReadWriteState public var style: TextStyle

	public let intrinsicContentSizeSignal: ReadSignal<CGSize>
	public let usePreferredMaxLayoutWidth: Bool

	private let intrinsicContentSizeReadWriteSignal = ReadWriteSignal<CGSize>(CGSize(width: 0, height: 0))

	public init(styledText: StyledText, usePreferredMaxLayoutWidth: Bool = true) {
		value = styledText.text
		style = styledText.style
		intrinsicContentSizeSignal = intrinsicContentSizeReadWriteSignal.readOnly()
		self.usePreferredMaxLayoutWidth = usePreferredMaxLayoutWidth
	}

	public init(value: DisplayableString, style: TextStyle, usePreferredMaxLayoutWidth: Bool = true) {
		self.init(
			styledText: StyledText(text: value, style: style),
			usePreferredMaxLayoutWidth: usePreferredMaxLayoutWidth
		)
	}
}

extension MultilineLabel: Viewable {
	public func materialize(events _: ViewableEvents) -> (UILabel, Disposable) {
		let bag = DisposeBag()

		let label = UILabel()
		bag += $value.atOnce().bindTo(label, \.value)

		bag += $style.atOnce().map { style -> TextStyle in
			style.restyled { (textStyle: inout TextStyle) in textStyle.numberOfLines = 0
				textStyle.lineBreakMode = .byWordWrapping
			}
		}.bindTo(label, \.style)

		bag += label.didLayoutSignal.onValue {
			if self.usePreferredMaxLayoutWidth { label.preferredMaxLayoutWidth = label.frame.size.width }
			self.intrinsicContentSizeReadWriteSignal.value = label.intrinsicContentSize
		}

		return (label, bag)
	}
}
