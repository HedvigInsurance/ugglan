import Flow
import Foundation
import UIKit
import hCore

public struct TextField {
	public let value: ReadWriteSignal<String>
	public let placeholder: ReadWriteSignal<String>
	public let enabledSignal: ReadWriteSignal<Bool>
	public let shouldReturn = Delegate<(String, UITextField), Bool>()

	public init(value: String, placeholder: String, enabled: Bool = true) {
		self.value = ReadWriteSignal(value)
		self.placeholder = ReadWriteSignal(placeholder)
		enabledSignal = ReadWriteSignal(enabled)
	}
}

extension TextField: Viewable {
	public func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
		let bag = DisposeBag()
		let view = UIControl()
		view.layer.cornerRadius = 8
		view.isUserInteractionEnabled = true

		view.snp.makeConstraints { make in make.height.equalTo(40) }

		view.layer.borderWidth = UIScreen.main.hairlineWidth
		bag += view.applyBorderColor { _ in .brand(.primaryBorderColor) }

		let paddingView = UIStackView()
		paddingView.isUserInteractionEnabled = true
		paddingView.axis = .vertical
		paddingView.isLayoutMarginsRelativeArrangement = true
		paddingView.layoutMargins = UIEdgeInsets(horizontalInset: 20, verticalInset: 3)
		view.addSubview(paddingView)

		paddingView.snp.makeConstraints { make in make.trailing.leading.top.bottom.equalToSuperview() }

		let textField = UITextField(value: "", placeholder: "", style: .default)
		textField.autocorrectionType = .no
		textField.autocapitalizationType = .none
		bag += value.atOnce().bidirectionallyBindTo(textField)
		bag += placeholder.atOnce().bindTo(textField, \.placeholder)
		bag += enabledSignal.atOnce().bindTo(textField, \.isEnabled)

		textField.snp.makeConstraints { make in make.height.equalTo(34) }

		bag += textField.shouldReturn.set { string -> Bool in
			self.shouldReturn.call((string, textField)) ?? false
		}

		paddingView.addArrangedSubview(textField)

		bag += view.signal(for: .touchDown).filter { !textField.isFirstResponder }.onValue { _ in
			textField.becomeFirstResponder()
		}

		return (view, bag)
	}
}
