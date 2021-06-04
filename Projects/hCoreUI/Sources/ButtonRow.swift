import Flow
import Form
import Foundation
import UIKit
import hCore

public struct ButtonRow {
	public static var trackingHandler: (_ row: Self) -> Void = { _ in }

	public let text: ReadWriteSignal<String>
	public let style: ReadWriteSignal<TextStyle>
	public let isHiddenSignal = ReadWriteSignal<Bool>(false)

	private let onSelectCallbacker = Callbacker<Void>()
	public let onSelect: Signal<Void>

	public init(
		text: String,
		style: TextStyle
	) {
		self.text = ReadWriteSignal(text)
		self.style = ReadWriteSignal(style)
		onSelect = onSelectCallbacker.providedSignal
	}

	public init(
		text: ReadWriteSignal<String>,
		style: ReadWriteSignal<TextStyle>
	) {
		self.text = text
		self.style = style
		onSelect = onSelectCallbacker.providedSignal
	}
}

extension ButtonRow: Viewable {
	public func materialize(events: SelectableViewableEvents) -> (RowView, Disposable) {
		let bag = DisposeBag()
		let row = RowView()
		row.alignment = .center

		bag += isHiddenSignal.atOnce().bindTo(row, \.isHidden)

		bag += events.onSelect.lazyBindTo(callbacker: onSelectCallbacker)

		let label = UILabel()

		bag += style.atOnce()
			.map { textStyle -> TextStyle in
				textStyle.restyled { (style: inout TextStyle) in style.alignment = .center }
			}
			.map { textStyle -> StyledText in StyledText(text: label.text ?? "", style: textStyle) }
			.bindTo(label, \.styledText)
		bag += text.atOnce().bindTo(label, \.text)

		label.snp.makeConstraints { make in make.height.equalTo(20) }

		bag += events.onSelect.onValue { Self.trackingHandler(self) }

		row.append(label)

		return (row, bag)
	}
}

public struct ButtonRowViewWrapper {
	private let onTapReadWriteSignal = ReadWriteSignal<Void>(())

	private let id = UUID()
	public let title: DisplayableString
	public let onTapSignal: Signal<Void>
	public let type: ButtonType
	public let animate: Bool
	private let isEnabled: Bool
	public let isEnabledSignal: ReadWriteSignal<Bool>

	public init(
		title: DisplayableString,
		type: ButtonType,
		isEnabled: Bool = true,
		animate: Bool = true
	) {
		self.title = title
		onTapSignal = onTapReadWriteSignal.plain()
		self.type = type
		isEnabledSignal = ReadWriteSignal<Bool>(isEnabled)
		self.isEnabled = isEnabled
		self.animate = animate
	}
}

extension ButtonRowViewWrapper: Viewable {
	public func materialize(events _: SelectableViewableEvents) -> (RowView, Disposable) {
		let button = Button(title: title, type: type, isEnabled: isEnabled, animate: animate)
		let rowView = RowView()
		let bag = DisposeBag()

		bag += rowView.append(button)

		bag += button.onTapSignal.bindTo(onTapReadWriteSignal)

		bag += isEnabledSignal.bindTo(button.isEnabled)

		return (rowView, bag)
	}
}
