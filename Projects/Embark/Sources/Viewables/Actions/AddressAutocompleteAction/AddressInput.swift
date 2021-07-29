import Flow
import Foundation
import Hero
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct AddressInput {
	let placeholder: String
	let textSignal = ReadWriteSignal<String>("")
	private let setTextSignal = ReadWriteSignal<String>("")
	let setIsFirstResponderSignal = ReadWriteSignal<Bool>(true)
	let shouldReturn = Delegate<String, Bool>()
	let didEditSignal = ReadWriteSignal<Void>(())

	var text: String {
		get {
			return textSignal.value
		}
		set(newText) {
			setTextSignal.value = newText
		}
	}
}

extension AddressInput: Viewable {
	func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
		let bag = DisposeBag()

		let box = UIView()
		box.backgroundColor = .brand(.secondaryBackground())
		box.layer.cornerRadius = 8
		bag += box.applyShadow { _ -> UIView.ShadowProperties in .embark }

		let boxStack = UIStackView()
		boxStack.axis = .vertical
		boxStack.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
		boxStack.isLayoutMarginsRelativeArrangement = true
		box.addSubview(boxStack)
		boxStack.snp.makeConstraints { make in
			make.top.bottom.right.left.equalToSuperview()
		}
		box.isUserInteractionEnabled = false

		let input = EmbarkInput(
			placeholder: placeholder,
			autocapitalisationType: .none,
			masking: Masking(type: .none),
			shouldAutoFocus: false,
			shouldAutoSize: true
		)

		let inputTextSignal = boxStack.addArranged(input)
		bag += inputTextSignal.bindTo(textSignal)
		bag += setTextSignal.bindTo(inputTextSignal)
		bag += input.didEditSignal.bindTo(didEditSignal)

		bag += input.shouldReturn.set { value -> Bool in self.shouldReturn.call(value) ?? false }

		bag += setIsFirstResponderSignal.bindTo(input.setIsFirstResponderSignal)

		return (box, bag)
	}
}
